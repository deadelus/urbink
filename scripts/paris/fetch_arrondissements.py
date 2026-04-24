#!/usr/bin/env python3
"""
Urbink — Fetch Paris arrondissements boundaries from OSM (Overpass API).

Queries the 20 arrondissements (admin_level=9) within Paris and saves their
real polygon outlines to assets/geo/paris/arrondissements.json.

Output format:
  [
    {"id": "arrond_1", "name": "1er", "center": [lat, lon],
     "polygon": [[lat, lon], ...]},
    ...
  ]

Usage:
  python3 scripts/paris/fetch_arrondissements.py
"""

import json
import math
import os
import urllib.request
import urllib.parse

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH   = os.path.join(SCRIPT_DIR, "..", "..", "urbink", "assets", "geo", "paris", "arrondissements.json")

GREEN = "\033[0;32m"
CYAN  = "\033[0;36m"
RED   = "\033[0;31m"
NC    = "\033[0m"

def log(msg): print(f"{CYAN}▶{NC} {msg}")
def ok(msg):  print(f"{GREEN}✅{NC} {msg}")
def err(msg): print(f"{RED}❌{NC} {msg}")


OVERPASS_MIRRORS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://overpass.openstreetmap.ru/api/interpreter",
]

QUERY = """
[out:json][timeout:120];
relation["boundary"="administrative"]["admin_level"="9"]["ref:INSEE"~"^751[0-9]{2}$"](48.81,2.22,48.91,2.47);
out body;
>;
out skel qt;
"""


def _overpass_fetch(query: str) -> dict:
    last_exc = None
    for mirror in OVERPASS_MIRRORS:
        url = mirror + "?" + urllib.parse.urlencode({"data": query})
        req = urllib.request.Request(url, headers={"User-Agent": "urbink-dev/1.0"})
        try:
            with urllib.request.urlopen(req, timeout=130) as r:
                return json.load(r)
        except Exception as exc:
            log(f"Mirror {mirror} — {exc}. Essai suivant…")
            last_exc = exc
    raise last_exc


def _dist2(a, b):
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2


def _simplify(points, tolerance=0.00005):
    """Douglas-Peucker."""
    if len(points) <= 2:
        return points

    def perp_dist(p, a, b):
        if a == b:
            return _dist2(p, a) ** 0.5
        dx, dy = b[0] - a[0], b[1] - a[1]
        norm = (dx * dx + dy * dy) ** 0.5
        return abs(dy * p[0] - dx * p[1] + b[0] * a[1] - b[1] * a[0]) / norm

    def rdp(pts):
        if len(pts) < 3:
            return pts
        max_d, idx = 0.0, 0
        for i in range(1, len(pts) - 1):
            d = perp_dist(pts[i], pts[0], pts[-1])
            if d > max_d:
                max_d, idx = d, i
        if max_d > tolerance:
            return rdp(pts[:idx + 1])[:-1] + rdp(pts[idx:])
        return [pts[0], pts[-1]]

    return rdp(points)


def _centroid(points):
    """Centroid géométrique d'un polygone."""
    n = len(points)
    if n == 0:
        return [0.0, 0.0]
    lat = sum(p[0] for p in points) / n
    lon = sum(p[1] for p in points) / n
    return [round(lat, 6), round(lon, 6)]


def _arrond_number(tags: dict) -> int | None:
    """Extrait le numéro d'arrondissement depuis les tags OSM."""
    # ref:INSEE = "75101"..."75120" → dernier 2 chiffres
    ref = tags.get("ref:INSEE", "")
    if ref.startswith("751") and len(ref) == 5:
        try:
            n = int(ref[3:])
            if 1 <= n <= 20:
                return n
        except ValueError:
            pass
    # Fallback sur le nom
    name = tags.get("name", "")
    for i in range(20, 0, -1):
        if str(i) in name:
            return i
    return None


def _french_ordinal(n: int) -> str:
    return "1er" if n == 1 else f"{n}e"


def assemble_ring(way_ids: list[int], ways: dict[int, list]) -> list:
    """Assemble des segments OSM en anneau continu."""
    segs = [ways[wid] for wid in way_ids if wid in ways]
    if not segs:
        return []

    ring = list(segs[0])
    used = {0}

    for _ in range(len(segs) - 1):
        last = ring[-1]
        best_i, best_rev, best_d = None, False, float("inf")
        for i, seg in enumerate(segs):
            if i in used:
                continue
            d_fwd = _dist2(last, seg[0])
            d_rev = _dist2(last, seg[-1])
            if d_fwd < best_d:
                best_d, best_i, best_rev = d_fwd, i, False
            if d_rev < best_d:
                best_d, best_i, best_rev = d_rev, i, True
        if best_i is None:
            break
        seg = segs[best_i]
        ring.extend(reversed(seg) if best_rev else seg)
        used.add(best_i)

    return ring


def fetch_arrondissements() -> list[dict]:
    log("Requête Overpass — 20 arrondissements de Paris…")
    raw = _overpass_fetch(QUERY)

    # Indexation
    nodes: dict[int, tuple] = {}
    ways: dict[int, list]   = {}
    relations: list         = []

    for el in raw["elements"]:
        t = el["type"]
        if t == "node":
            nodes[el["id"]] = (el["lat"], el["lon"])
        elif t == "way":
            pts = [(nodes[nid][0], nodes[nid][1]) for nid in el.get("nodes", []) if nid in nodes]
            ways[el["id"]] = pts
        elif t == "relation":
            relations.append(el)

    log(f"{len(relations)} relations trouvées")

    districts = []
    for rel in relations:
        tags = rel.get("tags", {})
        num  = _arrond_number(tags)
        if num is None:
            continue

        outer_ids = [
            m["ref"]
            for m in rel.get("members", [])
            if m.get("type") == "way" and m.get("role") == "outer"
        ]

        ring = assemble_ring(outer_ids, ways)
        if len(ring) < 3:
            err(f"  arrond_{num}: anneau insuffisant ({len(ring)} pts) — skipped")
            continue

        simplified = _simplify(ring, tolerance=0.00005)
        # Fermer l'anneau si nécessaire
        if simplified[0] != simplified[-1]:
            simplified.append(simplified[0])

        center = _centroid(simplified)

        districts.append({
            "id":      f"arrond_{num}",
            "name":    _french_ordinal(num),
            "center":  center,
            "polygon": [[round(p[0], 6), round(p[1], 6)] for p in simplified],
        })
        ok(f"  arrond_{num:2d} ({_french_ordinal(num):4s}) — {len(simplified)} pts")

    districts.sort(key=lambda d: int(d["id"].split("_")[1]))
    return districts


def main():
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    try:
        districts = fetch_arrondissements()
    except Exception as e:
        err(str(e))
        raise SystemExit(1)

    if not districts:
        err("Aucun arrondissement récupéré")
        raise SystemExit(1)

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(districts, f, separators=(",", ":"), ensure_ascii=False)

    ok(f"\n{len(districts)} arrondissements → {OUT_PATH}")


if __name__ == "__main__":
    main()
