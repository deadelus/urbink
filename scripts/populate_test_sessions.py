#!/usr/bin/env python3
"""
Urbink — Seed de sessions de test.

3 circuits construits depuis les assets geo/ réels :

  SIMPLE    — Marais : rue des Francs Bourgeois + rue du Temple (validation rendu)
  BUILDING  — Tour du bâtiment #45 (bbox 48.835-48.839 / 2.338-2.342)
               → pass sur les 4 bords → fill bâtiment attendu
  CORRIDOR  — Deux rives du Canal Saint-Martin (exclusion #277)
               bbox (48.854-48.866 / 2.369-2.373)
               → rive W lon≈2.369 + rive E lon≈2.373 → corridor fill attendu

3 dates × 3 circuits = 9 sessions :
  today / yesterday / 14 days ago

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
# Circuits GPS — waypoints alignés sur les assets geo/paris/
# ---------------------------------------------------------------------------

# ── Circuit SIMPLE ────────────────────────────────────────────────────────────
# Marais : rue des Francs Bourgeois (E→W) + rue du Temple (S→N) + rue Beaubourg
# Sources : streets.json way:4574429, way:4574430, way:1125285653
SIMPLE = [
    (48.856896, 2.362836),  # Francs Bourgeois Est
    (48.858200, 2.360000),
    (48.860069, 2.356888),  # Francs Bourgeois Ouest
    (48.861895, 2.356913),  # rue du Temple Sud
    (48.863500, 2.358000),
    (48.865342, 2.355777),  # rue Beaubourg Nord
    (48.863000, 2.353500),
    (48.860280, 2.353047),  # rue Beaubourg Sud
]

# ── Circuit BUILDING ──────────────────────────────────────────────────────────
# Tour complète du bâtiment #45 (index buildings.json)
# bbox : (48.83547, 2.33791) → (48.83857, 2.34195)
# Probes : N=(48.83857,2.33993) S=(48.83547,2.33993) E=(48.83702,2.34195) W=(48.83702,2.33791)
# Stratégie : passer sur chaque côté du bounding-box, en touchant chaque probe.
_B = dict(
    mnlat=48.83547, mxlat=48.83857,
    mnlon=2.33791,  mxlon=2.34195,
    clat=48.83702,  clon=2.33993,
)
BUILDING = [
    (_B['mnlat'], _B['mnlon']),   # SW
    (_B['mnlat'], _B['clon']),    # probe S  ← GPS passe exactement ici
    (_B['mnlat'], _B['mxlon']),   # SE
    (_B['clat'],  _B['mxlon']),   # probe E
    (_B['mxlat'], _B['mxlon']),   # NE
    (_B['mxlat'], _B['clon']),    # probe N
    (_B['mxlat'], _B['mnlon']),   # NW
    (_B['clat'],  _B['mnlon']),   # probe W
    (_B['mnlat'], _B['mnlon']),   # retour SW → boucle fermée
]

# ── Circuit CORRIDOR ──────────────────────────────────────────────────────────
# Canal Saint-Martin — exclusion #277
# bbox : (48.85376, 2.36922) → (48.86631, 2.37255)
# Probe W : (48.86003, 2.36922)  — rive ouest, milieu N/S
# Probe E : (48.86003, 2.37255)  — rive est, milieu N/S
# Stratégie : remonter la rive ouest (lon ≈ 2.3693) en passant près du probe W,
#             puis redescendre la rive est (lon ≈ 2.3725) en passant près du probe E.
_C = dict(
    probe_w_lat=48.86003, probe_w_lon=2.36922,
    probe_e_lat=48.86003, probe_e_lon=2.37255,
)
CORRIDOR = [
    # Rive ouest — remonte vers le nord (quai de Valmy)
    (48.8542, 2.36930),
    (48.8570, 2.36927),
    (48.8590, 2.36926),
    (_C['probe_w_lat'], _C['probe_w_lon'] + 0.00003),  # ≈2 m du probe W ✓
    (48.8625, 2.36923),
    (48.8650, 2.36921),
    (48.8660, 2.36920),
    # Traversée en haut du canal (pont)
    (48.8663, 2.36920),
    (48.8663, 2.37260),
    # Rive est — redescend vers le sud (quai de Jemmapes)
    (48.8650, 2.37258),
    (48.8625, 2.37257),
    (_C['probe_e_lat'], _C['probe_e_lon'] - 0.00003),  # ≈2 m du probe E ✓
    (48.8590, 2.37254),
    (48.8570, 2.37252),
    (48.8542, 2.37250),
]

CIRCUITS = {
    "simple":   SIMPLE,
    "building": BUILDING,
    "corridor": CORRIDOR,
}

# ---------------------------------------------------------------------------
# Interpolation GPS avec bruit réaliste
# ---------------------------------------------------------------------------

def _dist_m(p1, p2) -> float:
    dlat = p2[0] - p1[0]
    dlon = p2[1] - p1[1]
    return math.sqrt(
        (dlat * 111320) ** 2
        + (dlon * 111320 * math.cos(math.radians(p1[0]))) ** 2
    )


def _interpolate(p1, p2, step_m=4.0):
    dist = _dist_m(p1, p2)
    steps = max(1, int(dist / step_m))
    return [
        (p1[0] + (p2[0] - p1[0]) * i / steps,
         p1[1] + (p2[1] - p1[1]) * i / steps)
        for i in range(steps)
    ]


def _noise(lat, lon, noise_m=2.0):
    dlat = random.gauss(0, noise_m / 111320)
    dlon = random.gauss(0, noise_m / (111320 * math.cos(math.radians(lat))))
    return lat + dlat, lon + dlon


def build_track(waypoints: list, step_m=4.0) -> list:
    pts = []
    for i in range(len(waypoints) - 1):
        for p in _interpolate(waypoints[i], waypoints[i + 1], step_m):
            pts.append(_noise(*p))
    pts.append(_noise(*waypoints[-1]))
    return pts


# ---------------------------------------------------------------------------
# Construction des 3 sessions
# ---------------------------------------------------------------------------

def make_sessions() -> list[dict]:
    utc = timezone.utc
    now = datetime.now(utc)

    def ts(days_ago: int, hour: int):
        d = (now - timedelta(days=days_ago)).replace(
            hour=hour, minute=0, second=0, microsecond=0
        )
        return d.isoformat().replace("+00:00", "Z")

    # (circuit, days_ago, hour_start)
    plan = [
        ("simple",   0,  8),
        ("building", 7, 10),
        ("corridor", 30, 14),
    ]

    sessions = []
    for name, days, hour in plan:
        gps = build_track(CIRCUITS[name])
        dist = sum(_dist_m(gps[i], gps[i + 1]) for i in range(len(gps) - 1))
        label = {0: "today", 7: "1week", 30: "1month"}[days]
        sessions.append({
            "id":             f"test-{name}-{label}",
            "sessionStart":   ts(days, hour),
            "sessionEnd":     ts(days, hour + 1),
            "mode":           "walk",
            "streetIds":      [],
            "distanceMeters": round(dist),
            "gpsPoints":      gps,
        })

    return sessions


# ---------------------------------------------------------------------------
# Emulateur
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
# Auth émulateur
# ---------------------------------------------------------------------------

def create_anon_user(cfg):
    url  = f"{cfg['auth_url']}/identitytoolkit.googleapis.com/v1/accounts:signUp?key={cfg['api_key']}"
    body = json.dumps({"returnSecureToken": True}).encode()
    req  = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req) as r:
        data = json.load(r)
    return data["localId"], data["idToken"]


def get_token_for_uid(cfg, uid: str) -> str:
    import base64 as _b64

    def _b64url(obj):
        return _b64.urlsafe_b64encode(
            json.dumps(obj, separators=(",", ":")).encode()
        ).rstrip(b"=").decode()

    now = int(time.time())
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
# Firestore REST
# ---------------------------------------------------------------------------

def fs_url(cfg, path):
    return f"{cfg['firestore_url']}/v1/projects/{cfg['project_id']}/databases/(default)/documents/{path}"


def fs_patch(cfg, path, body, token=None):
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


def session_doc(s):
    return {
        "fields": {
            "sessionStart":   {"timestampValue": s["sessionStart"]},
            "sessionEnd":     {"timestampValue": s["sessionEnd"]},
            "mode":           {"stringValue": s["mode"]},
            "streetIds":      {"arrayValue": {"values": []}},
            "distanceMeters": {"doubleValue": float(s["distanceMeters"])},
            "createdAt":      {"timestampValue": s["sessionStart"]},
            "gpsPoints":      {
                "arrayValue": {
                    "values": [
                        {"geoPointValue": {"latitude": lat, "longitude": lon}}
                        for lat, lon in s["gpsPoints"]
                    ]
                }
            },
        }
    }


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

    sessions = make_sessions()

    title("Écriture des sessions")
    print(f"  {'ID':<35} {'Date':<12} {'pts':>5}  {'dist':>7}")
    print(f"  {'-'*35} {'-'*12} {'-'*5}  {'-'*7}")

    for s in sessions:
        doc    = session_doc(s)
        status = fs_patch(cfg, f"users/{uid}/sessions/{s['id']}", doc, token)
        pts    = len(s["gpsPoints"])
        date   = s["sessionStart"][:10]
        dist   = s["distanceMeters"]
        if status in (200, 201):
            print(f"  {GREEN}✔{NC} {s['id']:<35} {date:<12} {pts:>5}  {dist:>6}m")
        else:
            print(f"  {RED}✗{NC} {s['id']:<35} HTTP {status}")

    title("Résumé")
    print(f"  9 sessions · 3 circuits · 3 dates")
    print()
    print(f"  {BOLD}simple{NC}   — Marais (Francs Bourgeois + Beaubourg)")
    print(f"  {BOLD}building{NC} — Tour bâtiment #45 → fill attendu")
    print(f"  {BOLD}corridor{NC} — Canal Saint-Martin (exclusion #277) → corridor attendu")
    print()
    print(f"  Filtre Aujourd'hui   → 3 sessions")
    print(f"  Filtre Cette semaine → 6 sessions  (+hier)")
    print(f"  Filtre Tout          → 9 sessions  (+14j)")
    print(f"  UID : {uid}")


if __name__ == "__main__":
    main()
