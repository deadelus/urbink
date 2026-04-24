#!/usr/bin/env python3
"""
Urbink — Fetch inaccessible zones in Paris from OSM.

Fetches water bodies (rivers, canals, lakes, docks) and large buildings
within Paris bbox, saves to assets/geo/paris_exclusions.json.

Format: [ [[lat, lon], ...], ... ]  — list of polygons

Usage:
  python3 scripts/fetch_paris_exclusions.py
"""

import json
import os
import urllib.request
import urllib.parse

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
PARIS_BBOX   = "48.815,2.224,48.902,2.470"
OUT_PATH     = os.path.join(
    os.path.dirname(__file__), "..", "..", "urbink", "assets", "geo", "paris", "exclusions.json"
)

GREEN = "\033[0;32m"; CYAN = "\033[0;36m"; RED = "\033[0;31m"; NC = "\033[0m"
def log(m): print(f"{CYAN}▶{NC} {m}")
def ok(m):  print(f"{GREEN}✅{NC} {m}")
def err(m): print(f"{RED}❌{NC} {m}")


def fetch_exclusions() -> list:
    query = f"""
[out:json][timeout:90];
(
  way["natural"="water"]({PARIS_BBOX});
  way["waterway"~"^(river|canal|dock|basin)$"]({PARIS_BBOX});
  way["landuse"="reservoir"]({PARIS_BBOX});
  relation["natural"="water"]({PARIS_BBOX});
  relation["waterway"~"^(river|canal)$"]({PARIS_BBOX});
);
out geom;
"""
    log("Requête Overpass — zones inaccessibles (eau)...")
    url = OVERPASS_URL + "?" + urllib.parse.urlencode({"data": query})
    req = urllib.request.Request(url, headers={"User-Agent": "urbink-dev/1.0"})
    with urllib.request.urlopen(req, timeout=95) as r:
        raw = json.load(r)

    log(f"{len(raw['elements'])} éléments reçus")

    polygons = []
    for el in raw["elements"]:
        if el["type"] == "way":
            pts = [(n["lat"], n["lon"]) for n in el.get("geometry", [])]
            if len(pts) >= 3:
                simplified = _simplify(pts, 0.000020)
                if len(simplified) >= 3:
                    polygons.append([[round(lat, 6), round(lon, 6)] for lat, lon in simplified])

        elif el["type"] == "relation":
            # Prend le premier membre outer
            for m in el.get("members", []):
                if m.get("role") == "outer" and m.get("type") == "way":
                    pts = [(n["lat"], n["lon"]) for n in m.get("geometry", [])]
                    if len(pts) >= 3:
                        simplified = _simplify(pts, 0.000020)
                        if len(simplified) >= 3:
                            polygons.append([[round(lat, 6), round(lon, 6)] for lat, lon in simplified])

    return polygons


def _simplify(points, tolerance):
    if len(points) <= 2:
        return points

    def perp(p, a, b):
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
            d = perp(pts[i], pts[0], pts[-1])
            if d > max_d:
                max_d, idx = d, i
        if max_d > tolerance:
            return rdp(pts[:idx+1])[:-1] + rdp(pts[idx:])
        return [pts[0], pts[-1]]

    return rdp(points)


def main():
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    try:
        polygons = fetch_exclusions()
    except Exception as e:
        err(f"{e}"); raise SystemExit(1)

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(polygons, f, separators=(",", ":"))

    size_kb = os.path.getsize(OUT_PATH) / 1000
    ok(f"{len(polygons)} polygones → {OUT_PATH}  ({size_kb:.0f} KB)")


if __name__ == "__main__":
    main()
