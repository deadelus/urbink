#!/usr/bin/env python3
"""
Generate districts.json for Paris heatmap v1.
Contains 20 arrondissements with centers and approximate bounding box polygons.
"""
import json
from pathlib import Path

def generate_bbox_polygon(center_lat, center_lon, size_deg=0.01):
    """Generate a square polygon around a center point.

    Args:
        center_lat, center_lon: Center coordinates
        size_deg: Half-size in degrees (default ~1km)

    Returns:
        List of [lat, lon] pairs forming a square polygon
    """
    lat = center_lat
    lon = center_lon
    d = size_deg

    # Create a square: NW, NE, SE, SW, NW (closed)
    return [
        [lat + d, lon - d],  # NW
        [lat + d, lon + d],  # NE
        [lat - d, lon + d],  # SE
        [lat - d, lon - d],  # SW
        [lat + d, lon - d],  # NW (close)
    ]

def create_districts_json():
    """Create districts.json with polygons for each arrondissement."""
    # Official centers + sizes (some arrondissements are larger/smaller)
    districts_data = [
        {'center': [48.8622, 2.3352], 'size': 0.008, 'id': 'arrond_1', 'name': '1er'},
        {'center': [48.8703, 2.3422], 'size': 0.007, 'id': 'arrond_2', 'name': '2e'},
        {'center': [48.8626, 2.3546], 'size': 0.007, 'id': 'arrond_3', 'name': '3e'},
        {'center': [48.8524, 2.3612], 'size': 0.007, 'id': 'arrond_4', 'name': '4e'},
        {'center': [48.846, 2.3492], 'size': 0.008, 'id': 'arrond_5', 'name': '5e'},
        {'center': [48.8518, 2.3307], 'size': 0.008, 'id': 'arrond_6', 'name': '6e'},
        {'center': [48.856, 2.3088], 'size': 0.009, 'id': 'arrond_7', 'name': '7e'},
        {'center': [48.8718, 2.3073], 'size': 0.010, 'id': 'arrond_8', 'name': '8e'},
        {'center': [48.8761, 2.3348], 'size': 0.009, 'id': 'arrond_9', 'name': '9e'},
        {'center': [48.8703, 2.3632], 'size': 0.009, 'id': 'arrond_10', 'name': '10e'},
        {'center': [48.8591, 2.3788], 'size': 0.009, 'id': 'arrond_11', 'name': '11e'},
        {'center': [48.8355, 2.3932], 'size': 0.010, 'id': 'arrond_12', 'name': '12e'},
        {'center': [48.8252, 2.3634], 'size': 0.010, 'id': 'arrond_13', 'name': '13e'},
        {'center': [48.8336, 2.3287], 'size': 0.010, 'id': 'arrond_14', 'name': '14e'},
        {'center': [48.8451, 2.2854], 'size': 0.011, 'id': 'arrond_15', 'name': '15e'},
        {'center': [48.866, 2.2743], 'size': 0.011, 'id': 'arrond_16', 'name': '16e'},
        {'center': [48.8853, 2.2976], 'size': 0.010, 'id': 'arrond_17', 'name': '17e'},
        {'center': [48.8867, 2.343], 'size': 0.009, 'id': 'arrond_18', 'name': '18e'},
        {'center': [48.8823, 2.3856], 'size': 0.009, 'id': 'arrond_19', 'name': '19e'},
        {'center': [48.8603, 2.4005], 'size': 0.009, 'id': 'arrond_20', 'name': '20e'},
    ]

    districts = []
    for d in districts_data:
        polygon = generate_bbox_polygon(d['center'][0], d['center'][1], d['size'])
        districts.append({
            'id': d['id'],
            'name': d['name'],
            'center': d['center'],
            'polygon': polygon
        })

    return districts

def main():
    """Generate and save districts.json."""
    districts = create_districts_json()

    output_path = Path('urbink/assets/geo/paris/districts.json')
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w') as f:
        json.dump(districts, f, indent=2)

    print(f"✓ Generated {len(districts)} districts with bounding box polygons")
    print(f"  File: {output_path}")

if __name__ == '__main__':
    main()
