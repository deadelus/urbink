#!/usr/bin/env python3
"""
Urbink — Fetch large building footprints in Paris from OSM.

Fetches notable/large buildings (places of worship, museums, universities,
train stations, airports, hospitals, and large generic buildings) within the
Paris bounding box.  Only polygons with an area above a threshold are kept
to avoid tiny individual apartment buildings.

Output: assets/geo/paris_buildings.json
Format: [ [[lat, lon], ...], ... ]  — list of closed polygons

Usage:
  python3 scripts/fetch_paris_buildings.py

The generated file is used by [parisBuildingsProvider] to detect when the
GPS track has completely encircled a building footprint and fill it on the
exploration map.
"""

import json
import os
import math
import urllib.request
import urllib.parse

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
PARIS_BBOX   = "48.815,2.224,48.902,2.470"
OUT_PATH     = os.path.join(
    os.path.dirname(__file__), "..", "..", "urbink", "assets", "geo", "paris", "buildings.json"
)

# Minimum bounding-box area (degrees²) to keep a building.
# ~90m × 90m ≈ 0.000810° × 0.000810° ≈ 6.56e-7 deg²
# This filters out individual apartment blocks while keeping large landmarks.
MIN_BBOX_AREA_DEG2 = 6.0e-7

GREEN = "\033[0;32m"; CYAN = "\033[0;36m"; RED = "\033[0;31m"; NC = "\033[0m"
def log(m): print(f"{CYAN}▶{NC} {m}")
def ok(m):  print(f"{GREEN}✅{NC} {m}")
def err(m): print(f"{RED}❌{NC} {m}")


def fetch_buildings() -> list:
    query = f"""
[out:json][timeout:120];
(
  way["building"~"^(yes|public|civic|government|cathedral|church|mosque|synagogue|
      temple|chapel|museum|university|library|train_station|hotel|hospital|
      stadium|sports_hall|retail|commercial|industrial)$"]({PARIS_BBOX});
  relation["building"]["type"="multipolygon"]({PARIS_BBOX});
  way["amenity"~"^(place_of_worship|university|college|hospital|theatre|
      cinema|museum|library|townhall|courthouse|prison|arts_centre)$"]({PARIS_BBOX});
  way["tourism"~"^(museum|attraction|gallery|theme_park|zoo)$"]({PARIS_BBOX});
  way["historic"~"^(castle|monument|memorial|ruins|building|fort|palace)$"]({PARIS_BBOX});
  way["leisure"~"^(stadium|sports_centre|arena|pitch|track)$"]({PARIS_BBOX});
);
out geom;
"""
    log("Requête Overpass — grandes emprises bâties de Paris …")
    url = OVERPASS_URL + "?" + urllib.parse.urlencode({"data": query})
    req = urllib.request.Request(url, headers={"User-Agent": "urbink-dev/1.0"})
    with urllib.request.urlopen(req, timeout=125) as r:
        raw = json.load(r)

    log(f"{len(raw['elements'])} éléments reçus")

    polygons = []
    seen_ids  = set()

    for el in raw["elements"]:
        el_id = f"{el['type']}:{el['id']}"
        if el_id in seen_ids:
            continue
        seen_ids.add(el_id)

        pts = []
        if el["type"] == "way":
            pts = [(n["lat"], n["lon"]) for n in el.get("geometry", [])]
        elif el["type"] == "relation":
            for m in el.get("members", []):
                if m.get("role") == "outer" and m.get("type") == "way":
                    pts = [(n["lat"], n["lon"]) for n in m.get("geometry", [])]
                    break

        if len(pts) < 3:
            continue

        # Filter by bounding-box area
        lats = [p[0] for p in pts]
        lons = [p[1] for p in pts]
        bbox_area = (max(lats) - min(lats)) * (max(lons) - min(lons))
        if bbox_area < MIN_BBOX_AREA_DEG2:
            continue

        simplified = _simplify(pts, 0.000020)
        if len(simplified) >= 3:
            polygons.append(
                [[round(lat, 6), round(lon, 6)] for lat, lon in simplified]
            )

    return polygons


# ─── Douglas-Peucker simplification ──────────────────────────────────────────

def _simplify(points, tolerance):
    if len(points) <= 2:
        return points

    def perp(p, a, b):
        if a == b:
            return math.hypot(p[0] - a[0], p[1] - a[1])
        dx, dy = b[0] - a[0], b[1] - a[1]
        norm = math.hypot(dx, dy)
        return abs(dy * p[0] - dx * p[1] + b[0] * a[1] - b[1] * a[0]) / norm

    def rdp(pts, tol):
        if len(pts) <= 2:
            return pts
        dmax, idx = 0.0, 0
        for i in range(1, len(pts) - 1):
            d = perp(pts[i], pts[0], pts[-1])
            if d > dmax:
                dmax, idx = d, i
        if dmax >= tol:
            return rdp(pts[:idx + 1], tol)[:-1] + rdp(pts[idx:], tol)
        return [pts[0], pts[-1]]

    return rdp(points, tolerance)


def main():
    polygons = fetch_buildings()
    log(f"{len(polygons)} polygones retenus après filtrage")

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(polygons, f, separators=(",", ":"))

    size_kb = os.path.getsize(OUT_PATH) / 1024
    ok(f"Écrit → {OUT_PATH}  ({size_kb:.1f} Ko, {len(polygons)} bâtiments)")


if __name__ == "__main__":
    main()
