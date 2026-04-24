#!/usr/bin/env python3
"""
Urbink — Fetch Paris administrative boundary from OSM.

Downloads the outer ring of Paris (relation 71525) and saves it as
assets/geo/paris_boundary.json — a flat list of [lat, lon] points.

Usage:
  python3 scripts/fetch_paris_boundary.py
"""

import json
import os
import urllib.request
import urllib.parse

OVERPASS_URL  = "https://overpass-api.de/api/interpreter"
OUT_PATH      = os.path.join(os.path.dirname(__file__), "..", "..", "urbink", "assets", "geo", "paris", "boundary.json")

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


def _overpass_fetch(query: str, http_timeout: int) -> dict:
    """Essaie les mirrors Overpass dans l'ordre, retourne le JSON parsé."""
    last_exc = None
    for mirror in OVERPASS_MIRRORS:
        url = mirror + "?" + urllib.parse.urlencode({"data": query})
        req = urllib.request.Request(url, headers={"User-Agent": "urbink-dev/1.0"})
        try:
            with urllib.request.urlopen(req, timeout=http_timeout) as r:
                return json.load(r)
        except Exception as exc:
            log(f"Mirror {mirror} — {exc}. Essai suivant…")
            last_exc = exc
    raise last_exc


def fetch_boundary() -> list[list[float]]:
    # out body + >; out skel qt; est bien plus rapide que out geom; sur une relation
    query = """
[out:json][timeout:120];
relation(71525);
out body;
>;
out skel qt;
"""
    log("Requête Overpass — relation Paris (71525)...")
    raw  = _overpass_fetch(query, http_timeout=125)

    # Indexe les nodes et ways retournés par out skel qt
    nodes: dict[int, tuple[float, float]] = {}
    ways:  dict[int, list[tuple[float, float]]] = {}
    relation_el = None

    for el in raw["elements"]:
        if el["type"] == "node":
            nodes[el["id"]] = (el["lat"], el["lon"])
        elif el["type"] == "way":
            pts = [nodes[nid] for nid in el.get("nodes", []) if nid in nodes]
            ways[el["id"]] = pts
        elif el["type"] == "relation":
            relation_el = el

    if relation_el is None:
        raise ValueError("Relation 71525 introuvable dans la réponse Overpass")

    outer_way_ids = [
        m["ref"]
        for m in relation_el.get("members", [])
        if m.get("role") == "outer" and m.get("type") == "way"
    ]

    # Assemble les segments outer en un anneau continu
    segments = {wid: ways[wid] for wid in outer_way_ids if wid in ways}

    # Reconstruit l'anneau en chaînant les segments
    ring  = []
    used  = set()
    segs  = list(segments.values())

    if not segs:
        raise ValueError("Aucun segment outer trouvé")

    ring.extend(segs[0])
    used.add(0)

    for _ in range(len(segs) - 1):
        last = ring[-1]
        best_i, best_rev = None, False
        best_d = float("inf")
        for i, seg in enumerate(segs):
            if i in used:
                continue
            d_fwd = _dist2(last, seg[0])
            d_rev = _dist2(last, seg[-1])
            if d_fwd < best_d:
                best_d, best_i, best_rev = d_fwd, i, False
            if d_rev < best_d:
                best_d, best_i, best_rev = d_rev, i, True
        seg = segs[best_i]
        ring.extend(reversed(seg) if best_rev else seg)
        used.add(best_i)

    # Simplifie (Douglas-Peucker léger) pour réduire la taille
    simplified = _simplify(ring, tolerance=0.0001)
    return [[lat, lon] for lat, lon in simplified]


def _dist2(a, b):
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2


def _simplify(points, tolerance):
    """Douglas-Peucker simplifié."""
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


def main():
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    try:
        boundary = fetch_boundary()
    except Exception as e:
        print(f"{RED}❌{NC} {e}")
        raise SystemExit(1)

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(boundary, f, separators=(",", ":"))

    ok(f"{len(boundary)} points → {OUT_PATH}")


if __name__ == "__main__":
    main()
