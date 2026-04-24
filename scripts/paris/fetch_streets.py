#!/usr/bin/env python3
"""
Urbink — Fetch all Paris streets from OSM (full dataset).

Downloads all named ways within the Paris bounding box, simplifies
geometries, and saves to assets/geo/paris_streets_full.json.

Format:
  {
    "way:123456": { "name": "Rue de Rivoli", "pts": [[lat,lon], ...] },
    ...
  }

Usage:
  python3 scripts/fetch_paris_streets_full.py
"""

import json
import os
import urllib.request
import urllib.parse

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
# Bounding box légèrement plus large que Paris intra-muros
PARIS_BBOX   = "48.815,2.224,48.902,2.470"
OUT_PATH     = os.path.join(
    os.path.dirname(__file__), "..", "..", "urbink", "assets", "geo", "paris", "streets_full.json"
)

GREEN = "\033[0;32m"
CYAN  = "\033[0;36m"
RED   = "\033[0;31m"
NC    = "\033[0m"

def log(msg): print(f"{CYAN}▶{NC} {msg}")
def ok(msg):  print(f"{GREEN}✅{NC} {msg}")
def err(msg): print(f"{RED}❌{NC} {msg}")


def fetch_streets() -> dict:
    query = f"""
[out:json][timeout:120];
way["highway"~"primary|secondary|tertiary|residential|living_street|pedestrian|footway|cycleway|path|unclassified"]["name"]
  ({PARIS_BBOX});
out body;
>;
out skel qt;
"""
    log(f"Requête Overpass (bbox Paris complète)... patience ~30s")
    url = OVERPASS_URL + "?" + urllib.parse.urlencode({"data": query})
    req = urllib.request.Request(url, headers={"User-Agent": "urbink-dev/1.0"})
    with urllib.request.urlopen(req, timeout=130) as r:
        raw = json.load(r)

    log(f"{len(raw['elements'])} éléments OSM reçus")

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
        name = el.get("tags", {}).get("name", "")
        if not name:
            continue
        simplified = _simplify(pts, tolerance=0.000005)  # ~0.5m de tolérance
        streets[f"way:{el['id']}"] = {
            "name": name,
            "pts": [[round(lat, 6), round(lon, 6)] for lat, lon in simplified],
        }

    return streets


def _simplify(points, tolerance):
    if len(points) <= 2:
        return points

    def perp_dist(p, a, b):
        if a == b:
            return ((p[0]-a[0])**2 + (p[1]-a[1])**2) ** 0.5
        dx, dy = b[0]-a[0], b[1]-a[1]
        norm = (dx*dx + dy*dy) ** 0.5
        return abs(dy*p[0] - dx*p[1] + b[0]*a[1] - b[1]*a[0]) / norm

    def rdp(pts):
        if len(pts) < 3:
            return pts
        max_d, idx = 0.0, 0
        for i in range(1, len(pts)-1):
            d = perp_dist(pts[i], pts[0], pts[-1])
            if d > max_d:
                max_d, idx = d, i
        if max_d > tolerance:
            return rdp(pts[:idx+1])[:-1] + rdp(pts[idx:])
        return [pts[0], pts[-1]]

    return rdp(points)


def main():
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    try:
        streets = fetch_streets()
    except Exception as e:
        err(f"Erreur — {e}")
        raise SystemExit(1)

    if not streets:
        err("Aucune rue trouvée.")
        raise SystemExit(1)

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(streets, f, ensure_ascii=False, separators=(",", ":"))

    size_mb = os.path.getsize(OUT_PATH) / 1_000_000
    ok(f"{len(streets)} rues → {OUT_PATH}  ({size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
