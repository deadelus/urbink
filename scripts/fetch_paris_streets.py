#!/usr/bin/env python3
"""
Urbink — Fetch real Paris streets from Overpass API.

Fetches OSM ways with real IDs and coordinates, saves to fixtures/paris_streets.json.
Run once (or when you want fresher data):

  python3 scripts/fetch_paris_streets.py
  python3 scripts/fetch_paris_streets.py --bbox 48.855,2.340,48.865,2.360 --count 10
"""

import argparse
import json
import os
import urllib.request
import urllib.error
import urllib.parse

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
FIXTURES_PATH = os.path.join(os.path.dirname(__file__), "fixtures", "paris_streets.json")

GREEN = "\033[0;32m"
CYAN  = "\033[0;36m"
RED   = "\033[0;31m"
BOLD  = "\033[1m"
NC    = "\033[0m"

def log(msg): print(f"{CYAN}▶{NC} {msg}")
def ok(msg):  print(f"{GREEN}✅{NC} {msg}")
def err(msg): print(f"{RED}❌{NC} {msg}")


def fetch_streets(bbox: str, count: int) -> dict:
    """
    Returns { "way:<id>": [[lat, lon], ...], ... }
    bbox format: south,west,north,east  (e.g. 48.855,2.340,48.865,2.360)
    """
    query = f"""
[out:json][timeout:30];
way["highway"~"primary|secondary|tertiary|residential"]["name"]
  ({bbox});
out body;
>;
out skel qt;
"""
    log(f"Requête Overpass (bbox={bbox})...")
    url = OVERPASS_URL + "?" + urllib.parse.urlencode({"data": query})
    req = urllib.request.Request(url, headers={"User-Agent": "urbink-dev/1.0"})
    with urllib.request.urlopen(req, timeout=35) as r:
        raw = json.load(r)

    # Index nodes by id
    nodes = {
        el["id"]: (el["lat"], el["lon"])
        for el in raw["elements"]
        if el["type"] == "node"
    }

    streets = {}
    for el in raw["elements"]:
        if el["type"] != "way":
            continue
        pts = [nodes[nid] for nid in el.get("nodes", []) if nid in nodes]
        if len(pts) < 2:
            continue
        name = el.get("tags", {}).get("name", f"way:{el['id']}")
        streets[f"way:{el['id']}"] = {
            "name":   name,
            "points": pts,
        }
        if len(streets) >= count:
            break

    return streets


def main():
    parser = argparse.ArgumentParser(description="Fetch Paris streets from Overpass API")
    parser.add_argument(
        "--bbox",
        default="48.855,2.340,48.875,2.365",
        help="Bounding box: south,west,north,east (défaut: centre Paris 1er/2e)"
    )
    parser.add_argument(
        "--count",
        type=int,
        default=10,
        help="Nombre de rues à conserver (défaut: 10)"
    )
    args = parser.parse_args()

    try:
        streets = fetch_streets(args.bbox, args.count)
    except Exception as e:
        err(f"Erreur Overpass API — {e}")
        raise SystemExit(1)

    if not streets:
        err("Aucune rue trouvée dans cette bbox. Essaie d'élargir --bbox.")
        raise SystemExit(1)

    os.makedirs(os.path.dirname(FIXTURES_PATH), exist_ok=True)
    with open(FIXTURES_PATH, "w", encoding="utf-8") as f:
        json.dump(streets, f, ensure_ascii=False, indent=2)

    ok(f"{len(streets)} rues sauvegardées → {FIXTURES_PATH}")
    print()
    for way_id, data in streets.items():
        print(f"  {way_id}  {data['name']}  ({len(data['points'])} points)")
    print()


if __name__ == "__main__":
    main()
