#!/usr/bin/env python3
"""
Urbink — Seed de sessions de test avec vraies rues OSM Paris.

6 circuits dans 6 quartiers couvrant les 4 filtres temporels :
  MARAIS       (0j)  → Aujourd'hui  : 1 session visible
  OBERKAMPF    (2j)  → Cette semaine: 3 sessions cumulées
  CANAL        (5j)  → Cette semaine: 3 sessions cumulées
  ST_GERMAIN   (10j) → Ce mois      : 5 sessions cumulées
  MONTMARTRE   (20j) → Ce mois      : 5 sessions cumulées
  BASTILLE     (40j) → Tout seul.   : 6 sessions cumulées

Pour chaque circuit, seed de :
  - /users/{uid}/sessions/{id}       → streetIds, gpsPoints, dates, mode
  - /users/{uid}/streets/{streetId}  → points (GeoPoints), lastExploredAt

Les streetIds et géométries proviennent de urbink/assets/geo/paris/streets.json
(37 k segments OSM réels de Paris).

Usage :
  python3 scripts/populate_test_sessions.py --env local [--uid <uid>]
  python3 scripts/populate_test_sessions.py --env dev --uid <uid> --token <token>
"""

import argparse
import json
import math
import os
import random
import socket
import subprocess
import sys
import time
import urllib.request
import urllib.error
from datetime import datetime, timedelta, timezone

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STREETS_JSON = os.path.join(PROJECT_ROOT, "urbink/assets/geo/paris/streets.json")

# ---------------------------------------------------------------------------
# Config environnements
# ---------------------------------------------------------------------------

ENVS = {
    "local": {
        "firestore_url": "http://localhost:8080",
        "auth_url":      "http://localhost:9099",
        "project_id":    "urbink-dev",
        "api_key":       "fake-key",
    },
    "dev": {
        "firestore_url": "https://firestore.googleapis.com",
        "auth_url":      "https://identitytoolkit.googleapis.com",
        "project_id":    "urbink-dev",
        "api_key":       None,
    },
}

# ---------------------------------------------------------------------------
# Quartiers — définition des 6 circuits
#
# days_ago : jours depuis aujourd'hui
# bbox     : (lat_min, lat_max, lon_min, lon_max)
# sort_by  : "lon" (ouest→est) | "lat" (sud→nord) pour ordonner le parcours
# n        : nombre de segments de rue à inclure
# ---------------------------------------------------------------------------

NEIGHBORHOODS = [
    {
        "id":       "marais",
        "label":    "Marais — Francs Bourgeois · Beaubourg · Temple",
        "days_ago": 0,   "hour": 9,
        "bbox":     (48.857, 48.863, 2.354, 2.364),
        "sort_by":  "lon",
        "n":        18,
        "mode":     "walk",
    },
    {
        "id":       "oberkampf",
        "label":    "Oberkampf — République · Voltaire · Roquette",
        "days_ago": 2,   "hour": 18,
        "bbox":     (48.860, 48.870, 2.363, 2.380),
        "sort_by":  "lat",
        "n":        18,
        "mode":     "walk",
    },
    {
        "id":       "canal",
        "label":    "Canal Saint-Martin — quais Valmy · Jemmapes",
        "days_ago": 5,   "hour": 10,
        "bbox":     (48.854, 48.868, 2.365, 2.375),
        "sort_by":  "lat",
        "n":        18,
        "mode":     "bike",
    },
    {
        "id":       "st_germain",
        "label":    "Saint-Germain — Bac · Sèvres · Grenelle",
        "days_ago": 10,  "hour": 14,
        "bbox":     (48.848, 48.858, 2.323, 2.340),
        "sort_by":  "lon",
        "n":        18,
        "mode":     "walk",
    },
    {
        "id":       "montmartre",
        "label":    "Montmartre — Lepic · Clichy · Abbesses",
        "days_ago": 20,  "hour": 11,
        "bbox":     (48.882, 48.893, 2.334, 2.350),
        "sort_by":  "lat",
        "n":        18,
        "mode":     "walk",
    },
    {
        "id":       "bastille",
        "label":    "Bastille — Beaumarchais · Richard-Lenoir · Charonne",
        "days_ago": 40,  "hour": 16,
        "bbox":     (48.852, 48.860, 2.369, 2.386),
        "sort_by":  "lon",
        "n":        18,
        "mode":     "walk",
    },
]

MIN_PTS = 3  # points minimum par segment OSM

# ---------------------------------------------------------------------------
# Sélection des rues depuis streets.json
# ---------------------------------------------------------------------------

_streets_cache: dict | None = None


def load_streets() -> dict:
    global _streets_cache
    if _streets_cache is None:
        with open(STREETS_JSON) as f:
            _streets_cache = json.load(f)
    return _streets_cache


def _center(pts: list) -> tuple:
    return (
        sum(p[0] for p in pts) / len(pts),
        sum(p[1] for p in pts) / len(pts),
    )


def pick_streets(bbox: tuple, count: int, min_pts: int = MIN_PTS, sort_by: str = "lon") -> list:
    """Sélectionne <count> segments OSM dans la bbox, ordonnés géographiquement.

    Retourne : [(way_id, data_dict, center_tuple), ...]
    """
    lat_min, lat_max, lon_min, lon_max = bbox
    streets = load_streets()
    candidates = []
    for way_id, data in streets.items():
        pts = data.get("pts", [])
        if len(pts) < min_pts or not data.get("name"):
            continue
        c = _center(pts)
        if lat_min <= c[0] <= lat_max and lon_min <= c[1] <= lon_max:
            candidates.append((way_id, data, c))

    if sort_by == "lat":
        candidates.sort(key=lambda x: x[2][0])  # sud → nord
    else:
        candidates.sort(key=lambda x: x[2][1])  # ouest → est

    return candidates[:count]


# ---------------------------------------------------------------------------
# Interpolation GPS avec bruit réaliste
# ---------------------------------------------------------------------------

def _dist_m(p1: tuple, p2: tuple) -> float:
    dlat = p2[0] - p1[0]
    dlon = p2[1] - p1[1]
    return math.sqrt(
        (dlat * 111_320) ** 2
        + (dlon * 111_320 * math.cos(math.radians(p1[0]))) ** 2
    )


def _interpolate(p1: tuple, p2: tuple, step_m: float = 5.0) -> list:
    dist = _dist_m(p1, p2)
    steps = max(1, int(dist / step_m))
    return [
        (p1[0] + (p2[0] - p1[0]) * i / steps,
         p1[1] + (p2[1] - p1[1]) * i / steps)
        for i in range(steps)
    ]


def _noise(lat: float, lon: float, noise_m: float = 1.5) -> tuple:
    dlat = random.gauss(0, noise_m / 111_320)
    dlon = random.gauss(0, noise_m / (111_320 * math.cos(math.radians(lat))))
    return lat + dlat, lon + dlon


def build_gps_track(pts_list: list, step_m: float = 5.0) -> list:
    """Chaîne les pts de plusieurs segments en une trace GPS interpolée avec bruit."""
    track = []
    for pts in pts_list:
        for i in range(len(pts) - 1):
            for p in _interpolate(tuple(pts[i]), tuple(pts[i + 1]), step_m):
                track.append(_noise(*p))
        track.append(_noise(*pts[-1]))
    return track


# ---------------------------------------------------------------------------
# Construction des 6 circuits
# ---------------------------------------------------------------------------

def make_circuits() -> list:
    utc = timezone.utc
    now = datetime.now(utc)

    def ts(days_ago: int, hour: int) -> str:
        d = (now - timedelta(days=days_ago)).replace(
            hour=hour, minute=0, second=0, microsecond=0
        )
        return d.isoformat().replace("+00:00", "Z")

    title("Génération des circuits depuis streets.json")
    circuits = []

    for n in NEIGHBORHOODS:
        selected = pick_streets(n["bbox"], count=n["n"], sort_by=n["sort_by"])
        if not selected:
            err(f"  Aucune rue trouvée pour '{n['id']}'")
            continue

        street_ids     = [way_id for way_id, _, _ in selected]
        street_pts_map = {way_id: data["pts"] for way_id, data, _ in selected}
        gps_track      = build_gps_track([data["pts"] for _, data, _ in selected])
        dist           = sum(
            _dist_m(gps_track[i], gps_track[i + 1])
            for i in range(len(gps_track) - 1)
        )

        circuits.append({
            "id":             f"test-{n['id']}",
            "label":          n["label"],
            "days_ago":       n["days_ago"],
            "sessionStart":   ts(n["days_ago"], n["hour"]),
            "sessionEnd":     ts(n["days_ago"], n["hour"] + 1),
            "mode":           n["mode"],
            "streetIds":      street_ids,
            "street_pts_map": street_pts_map,
            "gpsPoints":      gps_track,
            "distanceMeters": round(dist),
        })
        ok(f"  {n['id']:<14} {len(street_ids)} rues · {len(gps_track)} pts GPS · {round(dist)}m")

    return circuits


# ---------------------------------------------------------------------------
# Documents Firestore
# ---------------------------------------------------------------------------

def session_doc(c: dict) -> dict:
    return {
        "fields": {
            "sessionStart":   {"timestampValue": c["sessionStart"]},
            "sessionEnd":     {"timestampValue": c["sessionEnd"]},
            "mode":           {"stringValue": c["mode"]},
            "streetIds": {
                "arrayValue": {
                    "values": [{"stringValue": sid} for sid in c["streetIds"]]
                }
            },
            "distanceMeters": {"doubleValue": float(c["distanceMeters"])},
            "createdAt":      {"timestampValue": c["sessionStart"]},
            "gpsPoints": {
                "arrayValue": {
                    "values": [
                        {"geoPointValue": {"latitude": lat, "longitude": lon}}
                        for lat, lon in c["gpsPoints"]
                    ]
                }
            },
        }
    }


def street_doc(pts: list, explored_at: str) -> dict:
    return {
        "fields": {
            "lastExploredAt": {"timestampValue": explored_at},
            "points": {
                "arrayValue": {
                    "values": [
                        {"geoPointValue": {"latitude": p[0], "longitude": p[1]}}
                        for p in pts
                    ]
                }
            },
        }
    }


# ---------------------------------------------------------------------------
# Firestore REST
# ---------------------------------------------------------------------------

def fs_url(cfg: dict, path: str) -> str:
    return f"{cfg['firestore_url']}/v1/projects/{cfg['project_id']}/databases/(default)/documents/{path}"


def fs_patch(cfg: dict, path: str, body: dict, token: str | None = None) -> int:
    url  = fs_url(cfg, path)
    data = json.dumps(body).encode()
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, data=data, headers=headers, method="PATCH")
            with urllib.request.urlopen(req, timeout=10) as r:
                return r.status
        except urllib.error.HTTPError as e:
            return e.code
        except Exception:
            if attempt < 2:
                time.sleep(2 ** attempt)
    return 0


# ---------------------------------------------------------------------------
# Auth émulateur
# ---------------------------------------------------------------------------

def create_anon_user(cfg: dict) -> tuple:
    url  = f"{cfg['auth_url']}/identitytoolkit.googleapis.com/v1/accounts:signUp?key={cfg['api_key']}"
    body = json.dumps({"returnSecureToken": True}).encode()
    req  = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req) as r:
        data = json.load(r)
    return data["localId"], data["idToken"]


def get_token_for_uid(cfg: dict, uid: str) -> str:
    import base64 as _b64

    def _b64url(obj):
        return _b64.urlsafe_b64encode(
            json.dumps(obj, separators=(",", ":")).encode()
        ).rstrip(b"=").decode()

    now   = int(time.time())
    token = ".".join([
        _b64url({"alg": "RS256", "typ": "JWT"}),
        _b64url({
            "iss": f"firebase-adminsdk@{cfg['project_id']}.iam.gserviceaccount.com",
            "sub": f"firebase-adminsdk@{cfg['project_id']}.iam.gserviceaccount.com",
            "aud": "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit",
            "iat": now, "exp": now + 3600, "uid": uid,
        }),
        "ZmFrZQ",
    ])
    url  = f"{cfg['auth_url']}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key={cfg['api_key']}"
    body = json.dumps({"token": token, "returnSecureToken": True}).encode()
    req  = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req) as r:
        return json.load(r)["idToken"]


# ---------------------------------------------------------------------------
# Émulateur
# ---------------------------------------------------------------------------

def _port_open(url: str) -> bool:
    try:
        host, port = url.replace("http://", "").split(":")
        with socket.create_connection((host, int(port)), timeout=1):
            return True
    except Exception:
        return False


def start_emulators(cfg: dict) -> None:
    if _port_open(cfg["auth_url"]) and _port_open(cfg["firestore_url"]):
        log("Émulateurs déjà actifs")
        return
    log("Lancement des émulateurs...")
    with open("/tmp/firebase-emulator.log", "w") as logf:
        subprocess.Popen(
            ["firebase", "emulators:start", "--only", "firestore,auth", "--host", "0.0.0.0"],
            cwd=PROJECT_ROOT, stdout=logf, stderr=logf,
        )
    for i in range(1, 31):
        if _port_open(cfg["auth_url"]) and _port_open(cfg["firestore_url"]):
            ok(f"Émulateurs prêts ({i}s)")
            return
        time.sleep(1)
        print(".", end="", flush=True)
    print()
    err("Timeout. Voir /tmp/firebase-emulator.log")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

GREEN = "\033[0;32m"
RED   = "\033[0;31m"
CYAN  = "\033[0;36m"
BOLD  = "\033[1m"
NC    = "\033[0m"


def log(m):   print(f"{CYAN}▶{NC} {m}")
def ok(m):    print(f"{GREEN}✅{NC} {m}")
def err(m):   print(f"{RED}❌{NC} {m}")
def title(m): print(f"\n{BOLD}── {m} ──────────────────────────{NC}")


# ---------------------------------------------------------------------------
# Résumé filtre temporel (calculé dynamiquement)
# ---------------------------------------------------------------------------

def _filter_label(days_ago: int) -> str:
    from datetime import date
    today     = date.today()
    sess_date = today - timedelta(days=days_ago)
    week_start  = today - timedelta(days=7)
    month_start = date(today.year, today.month, 1)
    if sess_date >= today:
        return "Aujourd'hui"
    if sess_date >= week_start:
        return "Cette semaine"
    if sess_date >= month_start:
        return "Ce mois"
    return "Tout"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--env",   choices=["local", "dev"], required=True)
    parser.add_argument("--uid",   default=None)
    parser.add_argument("--token", default=None)
    args = parser.parse_args()

    cfg   = ENVS[args.env]
    uid   = args.uid
    token = args.token

    title(f"Env : {args.env}")

    if args.env == "local":
        start_emulators(cfg)
        if uid:
            log(f"Auth comme UID existant : {uid}")
            token = get_token_for_uid(cfg, uid)
            ok(f"UID : {uid}")
        else:
            log("Création d'un utilisateur anonyme...")
            uid, token = create_anon_user(cfg)
            ok(f"UID créé : {uid}")
            print(f"\n{BOLD}  → Relance avec --uid {uid} pour cibler le même utilisateur.{NC}\n")
    else:
        if not uid or not token:
            err("--uid et --token requis pour env=dev")
            sys.exit(1)

    circuits = make_circuits()

    # ── Sessions ─────────────────────────────────────────────────────────────
    title("Écriture des sessions")
    print(f"  {'ID':<28} {'Date':<12} {'rues':>5}  {'pts':>5}  {'dist':>7}")
    print(f"  {'-'*28} {'-'*12} {'-'*5}  {'-'*5}  {'-'*7}")

    for c in circuits:
        doc    = session_doc(c)
        status = fs_patch(cfg, f"users/{uid}/sessions/{c['id']}", doc, token)
        sym    = f"{GREEN}✔{NC}" if status in (200, 201) else f"{RED}✗ {status}{NC}"
        print(
            f"  {sym} {c['id']:<26} {c['sessionStart'][:10]:<12}"
            f" {len(c['streetIds']):>5}  {len(c['gpsPoints']):>5}  {c['distanceMeters']:>6}m"
        )

    # ── Géométries des rues ───────────────────────────────────────────────────
    title("Écriture géométries rues (/streets/)")
    now_ts = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    # Déduplique les streetIds (une rue peut apparaître dans plusieurs circuits)
    street_pts_index: dict = {}
    for c in circuits:
        for sid, pts in c["street_pts_map"].items():
            if sid not in street_pts_index:
                street_pts_index[sid] = pts

    written = failed = 0
    for sid, pts in street_pts_index.items():
        status = fs_patch(cfg, f"users/{uid}/streets/{sid}", street_doc(pts, now_ts), token)
        if status in (200, 201):
            written += 1
        else:
            failed += 1
    ok(f"{written} segments écrits" + (f" · {RED}{failed} erreurs{NC}" if failed else ""))

    # ── Résumé ────────────────────────────────────────────────────────────────
    title("Résumé — filtres temporels")
    print(f"  {'Quartier':<16} {'Date':<12} {'Filtre visible dans…'}")
    print(f"  {'-'*16} {'-'*12} {'-'*30}")
    for c in circuits:
        flabel = _filter_label(c["days_ago"])
        print(f"  {c['id']:<16} {c['sessionStart'][:10]:<12} {flabel}")

    cumul = lambda max_days: sum(1 for c in circuits if c["days_ago"] <= max_days)
    print()
    print(f"  Aujourd'hui   → {cumul(0)} session(s)")
    print(f"  Cette semaine → {cumul(6)} session(s) cumulées")
    # Ce mois = depuis le 1er du mois courant
    from datetime import date
    days_since_month_start = date.today().day - 1
    print(f"  Ce mois       → {cumul(days_since_month_start)} session(s) cumulées  (depuis le 1er du mois)")
    print(f"  Tout          → {len(circuits)} session(s)")
    print(f"\n  {BOLD}UID : {uid}{NC}")
    print()


if __name__ == "__main__":
    main()
