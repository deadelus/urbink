#!/usr/bin/env python3
"""
Urbink — Fetch Paris quartiers administratifs from OSM (admin_level=10).

80 quartiers (4 par arrondissement), vraies géométries OSM.
Output : assets/geo/paris/quartiers.json

Usage:
  python3 scripts/paris/fetch_quartiers.py
"""

import json
import os
import urllib.request
import urllib.parse

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PATH   = os.path.join(SCRIPT_DIR, "..", "..", "urbink", "assets", "geo", "paris", "quartiers.json")

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
area(3600071525)->.paris;
relation["boundary"="administrative"]["admin_level"="10"](area.paris);
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


def _simplify(points, tolerance=0.00003):
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
    n = len(points)
    if n == 0:
        return [0.0, 0.0]
    return [round(sum(p[0] for p in points) / n, 6),
            round(sum(p[1] for p in points) / n, 6)]


def assemble_ring(way_ids, ways):
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
            d_rev  = _dist2(last, seg[-1])
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


def fetch_quartiers() -> list[dict]:
    log("Requête Overpass — 80 quartiers de Paris (admin_level=10)…")
    raw = _overpass_fetch(QUERY)

    nodes, ways, relations = {}, {}, []
    for el in raw["elements"]:
        t = el["type"]
        if t == "node":
            nodes[el["id"]] = (el["lat"], el["lon"])
        elif t == "way":
            pts = [(nodes[n][0], nodes[n][1]) for n in el.get("nodes", []) if n in nodes]
            ways[el["id"]] = pts
        elif t == "relation":
            relations.append(el)

    log(f"{len(relations)} relations trouvées")

    quartiers = []
    for rel in relations:
        tags = rel.get("tags", {})
        raw_name = tags.get("name", "").strip()
        if not raw_name:
            continue
        # "Quartier du Bel-Air" → "Bel-Air", "Quartier Les Halles" → "Les Halles"
        import re as _re
        name = _re.sub(r"^[Qq]uartier\s+(de\s+la?\s+|des?\s+|du\s+|d['']\s*)?", "", raw_name).strip()
        if not name:
            name = raw_name

        outer_ids = [
            m["ref"] for m in rel.get("members", [])
            if m.get("type") == "way" and m.get("role") == "outer"
        ]
        ring = assemble_ring(outer_ids, ways)
        if len(ring) < 3:
            continue

        simplified = _simplify(ring, tolerance=0.00003)
        if simplified[0] != simplified[-1]:
            simplified.append(simplified[0])

        quartiers.append({
            "id":      f"q_{tags.get('ref:INSEE', rel['id'])}",
            "name":    name,
            "center":  _centroid(simplified),
            "polygon": [[round(p[0], 6), round(p[1], 6)] for p in simplified],
        })

    quartiers.sort(key=lambda q: q["id"])
    ok(f"{len(quartiers)} quartiers traités")
    return quartiers


def main():
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    try:
        quartiers = fetch_quartiers()
    except Exception as e:
        err(str(e))
        raise SystemExit(1)

    if not quartiers:
        err("Aucun quartier récupéré")
        raise SystemExit(1)

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(quartiers, f, separators=(",", ":"), ensure_ascii=False)

    ok(f"→ {OUT_PATH}")


if __name__ == "__main__":
    main()
