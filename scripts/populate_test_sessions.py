#!/usr/bin/env python3
"""
Urbink — Populate test sessions (Story 3.2 — filtrage temporel).

Crée dans Firestore :
  /users/{uid}/streets/{streetId}   → 5 rues (Paris) avec géométries GeoPoint
  /users/{uid}/sessions/{sessionId} → 8 sessions réparties sur 4 périodes :
      · aujourd'hui   × 3
      · cette semaine × 2  (3j, 5j)
      · ce mois       × 2  (12j, 18j)
      · historique    × 1  (45j)

Usage :
  # Local (émulateur)
  python3 scripts/populate_test_sessions.py --env local

  # Dev / Staging (fournir UID + ID token de l'utilisateur connecté)
  python3 scripts/populate_test_sessions.py --env dev   --uid <uid> --token <idToken>
  python3 scripts/populate_test_sessions.py --env staging --uid <uid> --token <idToken>

Obtenir son ID token dans l'app Flutter (debug) :
  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();
  debugPrint('ID TOKEN: $token');
"""

import argparse
import json
import os
import socket
import subprocess
import sys
import time
import uuid
import urllib.request
import urllib.error
from datetime import datetime, timedelta, timezone

PROJECT_ROOT   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIXTURES_PATH  = os.path.join(os.path.dirname(__file__), "fixtures", "paris_streets.json")

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

ENVS = {
    "local": {
        "firestore_url": "http://localhost:8080",
        "auth_url":      "http://localhost:9099",
        "project_id":    "demo-no-project",
        "api_key":       "fake-key",
    },
    "dev": {
        "firestore_url": "https://firestore.googleapis.com",
        "auth_url":      "https://identitytoolkit.googleapis.com",
        "project_id":    "urbink-dev",
        "api_key":       None,  # résolu depuis firebase_options.dart
    },
    "staging": {
        "firestore_url": "https://firestore.googleapis.com",
        "auth_url":      "https://identitytoolkit.googleapis.com",
        "project_id":    "urbink-staging",
        "api_key":       None,
    },
}

# ---------------------------------------------------------------------------
# Rues de test — chargées depuis fixtures/paris_streets.json
# ---------------------------------------------------------------------------

def load_streets() -> dict:
    if not os.path.exists(FIXTURES_PATH):
        print(f"\033[0;31m❌\033[0m Fixtures introuvables : {FIXTURES_PATH}")
        print("  → Lance d'abord : python3 scripts/fetch_paris_streets.py")
        sys.exit(1)
    with open(FIXTURES_PATH, encoding="utf-8") as f:
        data = json.load(f)
    # Normalise : { way_id: [(lat, lon), ...] }
    return {
        way_id: [tuple(pt) for pt in entry["points"]]
        for way_id, entry in data.items()
    }

# ---------------------------------------------------------------------------
# Sessions de test
# ---------------------------------------------------------------------------

def make_sessions(street_ids: list[str]):
    utc = timezone.utc
    now = datetime.now(utc)

    def ts(days_ago, hour_start, duration_h=1):
        start = (now - timedelta(days=days_ago)).replace(
            hour=hour_start, minute=0, second=0, microsecond=0
        )
        end = start + timedelta(hours=duration_h)
        return start.isoformat().replace("+00:00", "Z"), end.isoformat().replace("+00:00", "Z")

    # Distribute street IDs across sessions — works with any number of streets
    def pick(*indices):
        return [street_ids[i % len(street_ids)] for i in indices]

    return [
        # ── Aujourd'hui ──────────────────────────────────────────────
        {"id": "session-today-1", "sessionStart": ts(0, 8)[0],  "sessionEnd": ts(0, 8)[1],
         "mode": "walk", "streetIds": pick(0, 1), "distanceMeters": 1200.0},
        {"id": "session-today-2", "sessionStart": ts(0, 12)[0], "sessionEnd": ts(0, 12)[1],
         "mode": "bike", "streetIds": pick(2),    "distanceMeters": 600.0},
        {"id": "session-today-3", "sessionStart": ts(0, 17)[0], "sessionEnd": ts(0, 17, 0.5)[1],
         "mode": "walk", "streetIds": pick(3),    "distanceMeters": 500.0},
        # ── Cette semaine (3j et 5j) ──────────────────────────────────
        {"id": "session-week-1",  "sessionStart": ts(3, 10)[0], "sessionEnd": ts(3, 10)[1],
         "mode": "walk", "streetIds": pick(0, 4), "distanceMeters": 1500.0},
        {"id": "session-week-2",  "sessionStart": ts(5, 15)[0], "sessionEnd": ts(5, 15)[1],
         "mode": "run",  "streetIds": pick(1, 2), "distanceMeters": 1800.0},
        # ── Ce mois (12j et 18j) ──────────────────────────────────────
        {"id": "session-month-1", "sessionStart": ts(12, 9)[0], "sessionEnd": ts(12, 9, 1.5)[1],
         "mode": "bike", "streetIds": pick(3, 4), "distanceMeters": 2000.0},
        {"id": "session-month-2", "sessionStart": ts(18, 8)[0], "sessionEnd": ts(18, 8)[1],
         "mode": "walk", "streetIds": pick(0),    "distanceMeters": 800.0},
        # ── Historique (45j) ──────────────────────────────────────────
        {"id": "session-old-1",   "sessionStart": ts(45, 10)[0], "sessionEnd": ts(45, 10)[1],
         "mode": "walk", "streetIds": pick(1, 3), "distanceMeters": 1600.0},
    ]


# ---------------------------------------------------------------------------
# Émulateur — démarrage automatique
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
        log("Émulateurs déjà actifs — skip")
        return

    log("Lancement firebase emulators:start --only firestore,auth ...")
    with open("/tmp/firebase-emulator.log", "w") as logf:
        proc = subprocess.Popen(
            ["firebase", "emulators:start", "--only", "firestore,auth"],
            cwd=PROJECT_ROOT,
            stdout=logf,
            stderr=logf,
        )
    with open("/tmp/firebase-emulator.pid", "w") as f:
        f.write(str(proc.pid))

    log("Attente démarrage (max 30s)...")
    for i in range(1, 31):
        if _port_open(cfg["auth_url"]) and _port_open(cfg["firestore_url"]):
            print(f"\033[0;32m✔ Émulateurs prêts\033[0m ({i}s)")
            return
        time.sleep(1)
        print(".", end="", flush=True)
    print()
    err("Timeout — émulateurs non démarrés. Voir /tmp/firebase-emulator.log")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Firestore REST helpers
# ---------------------------------------------------------------------------

def fs_url(cfg, path):
    base = cfg["firestore_url"]
    pid  = cfg["project_id"]
    return f"{base}/v1/projects/{pid}/databases/(default)/documents/{path}"


def fs_patch(cfg, path, body, token=None):
    url  = fs_url(cfg, path)
    data = json.dumps(body).encode()
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, data=data, headers=headers, method="PATCH")
    try:
        with urllib.request.urlopen(req) as r:
            return r.status
    except urllib.error.HTTPError as e:
        print(f"  ⚠️  HTTP {e.code} — {e.read().decode()[:200]}")
        return e.code


# ---------------------------------------------------------------------------
# Auth — emulateur
# ---------------------------------------------------------------------------

def create_anon_user(cfg):
    if cfg["auth_url"] == "http://localhost:9099":
        url = f"{cfg['auth_url']}/identitytoolkit.googleapis.com/v1/accounts:signUp?key={cfg['api_key']}"
    else:
        url = f"{cfg['auth_url']}/v1/accounts:signUp?key={cfg['api_key']}"

    body = json.dumps({"returnSecureToken": True}).encode()
    req  = urllib.request.Request(url, data=body,
                                   headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req) as r:
        data = json.load(r)
    return data["localId"], data["idToken"]


# ---------------------------------------------------------------------------
# JSON builders
# ---------------------------------------------------------------------------

def street_doc(points):
    return {
        "fields": {
            "points": {
                "arrayValue": {
                    "values": [
                        {"geoPointValue": {"latitude": lat, "longitude": lon}}
                        for lat, lon in points
                    ]
                }
            }
        }
    }


def session_doc(s):
    now_ts = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    return {
        "fields": {
            "sessionStart":    {"timestampValue": s["sessionStart"]},
            "sessionEnd":      {"timestampValue": s["sessionEnd"]},
            "mode":            {"stringValue": s["mode"]},
            "streetIds":       {
                "arrayValue": {
                    "values": [{"stringValue": sid} for sid in s["streetIds"]]
                }
            },
            "distanceMeters":  {"doubleValue": s["distanceMeters"]},
            "createdAt":       {"timestampValue": s["sessionStart"]},
        }
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

GREEN  = "\033[0;32m"
RED    = "\033[0;31m"
CYAN   = "\033[0;36m"
BOLD   = "\033[1m"
NC     = "\033[0m"


def log(msg):   print(f"{CYAN}▶{NC} {msg}")
def ok(msg):    print(f"{GREEN}✅{NC} {msg}")
def err(msg):   print(f"{RED}❌{NC} {msg}")
def title(msg): print(f"\n{BOLD}── {msg} ──────────────────────────{NC}")


def main():
    parser = argparse.ArgumentParser(description="Populate Firestore test sessions")
    parser.add_argument("--env",   choices=["local", "dev", "staging"], required=True)
    parser.add_argument("--uid",   help="UID utilisateur (requis pour dev/staging)")
    parser.add_argument("--token", help="ID token Firebase (requis pour dev/staging)")
    args = parser.parse_args()

    cfg = ENVS[args.env]
    token = None
    uid   = args.uid

    # ── Auth ──────────────────────────────────────────────────────────
    title(f"Environnement : {args.env}")

    if args.env == "local":
        start_emulators(cfg)
        log("Création d'un utilisateur anonyme sur l'émulateur...")
        uid, token = create_anon_user(cfg)
        ok(f"UID : {uid}")
        print(f"\n{BOLD}  → Lance l'app avec FIREBASE_AUTH_UID={uid} pour voir ces données.{NC}")
        print(f"  → Ou utilise cet UID dans la console Firebase Emulator UI.\n")
    else:
        if not uid or not args.token:
            err("--uid et --token sont requis pour dev/staging.")
            print("""
Comment obtenir votre ID token (Flutter debug) :
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  debugPrint('TOKEN: $token');
""")
            sys.exit(1)
        token = args.token
        ok(f"UID : {uid}")

    streets  = load_streets()
    sessions = make_sessions(list(streets.keys()))

    # ── Streets ───────────────────────────────────────────────────────
    title("Écriture des rues (streets)")
    for street_id, points in streets.items():
        doc    = street_doc(points)
        path   = f"users/{uid}/streets/{street_id}"
        status = fs_patch(cfg, path, doc, token)
        if status in (200, 201):
            ok(f"{street_id} ({len(points)} points)")
        else:
            err(f"{street_id} — HTTP {status}")

    # ── Sessions ─────────────────────────────────────────────────────
    title("Écriture des sessions")
    for s in sessions:
        doc    = session_doc(s)
        path   = f"users/{uid}/sessions/{s['id']}"
        status = fs_patch(cfg, path, doc, token)
        if status in (200, 201):
            ok(f"{s['id']}  start={s['sessionStart'][:10]}  streets={s['streetIds']}")
        else:
            err(f"{s['id']} — HTTP {status}")

    # ── Résumé ───────────────────────────────────────────────────────
    title("Résumé")
    print(f"  {len(streets)} rues · {len(sessions)} sessions")
    print("""
  Filtres attendus :
    Aujourd'hui   → 3 sessions
    Cette semaine → 5 sessions
    Ce mois       → 7 sessions
    Tout          → 8 sessions
""")


if __name__ == "__main__":
    main()
