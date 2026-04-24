#!/usr/bin/env python3
"""Generate test GPS tracks for Urbink testing.

Three types of tracks:
1. Simple linear tracks
2. Building encirclement tracks (to test building coloring)
3. Canal/river two-banks tracks
"""

import json
from pathlib import Path


def generate_simple_tracks():
    """Generate simple linear tracks across Paris streets."""
    return [
        {
            "id": "simple_champs_elysees",
            "name": "Simple: Champs-Élysées",
            "type": "simple",
            "coordinates": [
                [48.8698, 2.3076],  # Arc de Triomphe
                [48.8685, 2.3085],
                [48.8672, 2.3095],
                [48.8659, 2.3105],
                [48.8646, 2.3115],
                [48.8633, 2.3125],
                [48.8620, 2.3135],
                [48.8607, 2.3145],  # Place de la Concorde
            ],
        },
        {
            "id": "simple_seine_left_bank",
            "name": "Simple: Left Bank Seine",
            "type": "simple",
            "coordinates": [
                [48.8504, 2.3490],  # Notre-Dame
                [48.8495, 2.3510],
                [48.8486, 2.3530],
                [48.8477, 2.3550],
                [48.8468, 2.3570],
                [48.8459, 2.3590],
                [48.8450, 2.3610],
                [48.8441, 2.3630],
            ],
        },
        {
            "id": "simple_montmartre_loop",
            "name": "Simple: Montmartre ascent",
            "type": "simple",
            "coordinates": [
                [48.8844, 2.3431],  # Pigalle
                [48.8855, 2.3420],
                [48.8866, 2.3410],
                [48.8877, 2.3400],
                [48.8888, 2.3390],
                [48.8899, 2.3380],
                [48.8910, 2.3370],  # Sacré-Cœur
            ],
        },
    ]


def generate_building_encirclement_tracks():
    """Generate tracks that encircle buildings to test coloring."""
    return [
        {
            "id": "encircle_notre_dame",
            "name": "Encirclement: Notre-Dame",
            "type": "encirclement",
            "description": "Circle around Notre-Dame to test building coloring",
            "coordinates": [
                # Building coordinates around Notre-Dame
                [48.8530, 2.3496],  # East
                [48.8524, 2.3496],  # North-East
                [48.8520, 2.3490],  # North
                [48.8520, 2.3480],  # North-West
                [48.8524, 2.3472],  # West
                [48.8530, 2.3472],  # South-West
                [48.8536, 2.3480],  # South
                [48.8536, 2.3490],  # South-East
                [48.8530, 2.3496],  # Back to start
            ],
        },
        {
            "id": "encircle_eiffel",
            "name": "Encirclement: Eiffel Tower Plaza",
            "type": "encirclement",
            "description": "Circle around Eiffel Tower area buildings",
            "coordinates": [
                # Champ de Mars perimeter
                [48.8584, 2.2945],  # East
                [48.8570, 2.2945],  # North-East
                [48.8556, 2.2935],  # North
                [48.8556, 2.2915],  # North-West
                [48.8570, 2.2905],  # West
                [48.8584, 2.2905],  # South-West
                [48.8598, 2.2915],  # South
                [48.8598, 2.2935],  # South-East
                [48.8584, 2.2945],  # Back to start
            ],
        },
        {
            "id": "encircle_louvre",
            "name": "Encirclement: Louvre",
            "type": "encirclement",
            "description": "Rectangle around Louvre museum",
            "coordinates": [
                [48.8626, 2.3355],  # NE corner
                [48.8605, 2.3355],  # NW corner
                [48.8605, 2.3325],  # SW corner
                [48.8626, 2.3325],  # SE corner
                [48.8626, 2.3355],  # Back to start
            ],
        },
        {
            "id": "double_building_loop",
            "name": "Encirclement: Twin building loop",
            "type": "encirclement",
            "description": "Encircle two adjacent buildings (figure-8 pattern)",
            "coordinates": [
                # First loop (right building)
                [48.8700, 2.3100],
                [48.8695, 2.3100],
                [48.8692, 2.3095],
                [48.8692, 2.3085],
                [48.8695, 2.3080],
                [48.8700, 2.3080],
                [48.8703, 2.3085],
                [48.8703, 2.3095],
                [48.8700, 2.3100],
                # Cross to second building
                [48.8705, 2.3090],
                # Second loop (left building)
                [48.8710, 2.3085],
                [48.8705, 2.3085],
                [48.8703, 2.3080],
                [48.8703, 2.3070],
                [48.8705, 2.3065],
                [48.8710, 2.3065],
                [48.8712, 2.3070],
                [48.8712, 2.3080],
                [48.8710, 2.3085],
            ],
        },
    ]


def generate_canal_river_tracks():
    """Generate tracks that follow both banks of canals/rivers."""
    return [
        {
            "id": "canal_st_martin_two_banks",
            "name": "Canal Saint-Martin: Two banks",
            "type": "canal_two_banks",
            "description": "Follow Canal Saint-Martin from both banks to test coloring between banks",
            "coordinates": [
                # Start at République, north bank going east
                [48.8665, 2.3650],  # République bridge
                [48.8670, 2.3670],  # North bank
                [48.8675, 2.3690],
                [48.8680, 2.3710],
                [48.8685, 2.3730],
                [48.8690, 2.3750],
                [48.8695, 2.3770],  # Jaurès area
                # Transition to south bank
                [48.8693, 2.3780],
                # South bank going back west
                [48.8688, 2.3760],
                [48.8683, 2.3740],
                [48.8678, 2.3720],
                [48.8673, 2.3700],
                [48.8668, 2.3680],
                [48.8663, 2.3660],  # Back to République
            ],
        },
        {
            "id": "seine_both_banks_ile_st_louis",
            "name": "Seine: Both banks - Île Saint-Louis",
            "type": "canal_two_banks",
            "description": "Circle around Île Saint-Louis, touching both Seine banks",
            "coordinates": [
                # Left bank
                [48.8525, 2.3540],
                [48.8530, 2.3545],
                [48.8535, 2.3550],
                [48.8540, 2.3555],
                # Cross to right side
                [48.8545, 2.3560],
                # Right bank (Île Saint-Louis east side)
                [48.8543, 2.3570],
                [48.8538, 2.3575],
                [48.8533, 2.3570],
                [48.8528, 2.3565],
                [48.8523, 2.3560],
                # Cross back to left
                [48.8520, 2.3550],
            ],
        },
        {
            "id": "ourcq_canal_loop",
            "name": "Ourcq Canal: Full loop both banks",
            "type": "canal_two_banks",
            "description": "Loop along both banks of Ourcq Canal",
            "coordinates": [
                # Stalingrad area, north bank going east
                [48.8770, 2.3720],
                [48.8775, 2.3740],
                [48.8780, 2.3760],
                [48.8785, 2.3780],
                [48.8790, 2.3800],
                # Cross to south bank
                [48.8788, 2.3810],
                # South bank going back west
                [48.8783, 2.3790],
                [48.8778, 2.3770],
                [48.8773, 2.3750],
                [48.8768, 2.3730],
                # Cross back to north
                [48.8770, 2.3720],
            ],
        },
    ]


def save_tracks_to_firebase_json():
    """Save all tracks to a JSON file suitable for Firebase import or direct use."""
    all_tracks = (
        generate_simple_tracks()
        + generate_building_encirclement_tracks()
        + generate_canal_river_tracks()
    )

    # Add timestamps and structure
    for track in all_tracks:
        track["timestamp"] = 1712000000000  # Unix timestamp in ms
        track["distance_km"] = round(len(track["coordinates"]) * 0.1, 2)  # Rough estimate

    output_dir = Path("/Users/geoffreytrambolho/Code/urbink/scripts/paris")
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / "test_tracks.json"
    with open(output_file, "w") as f:
        json.dump(all_tracks, f, indent=2)

    print(f"✅ Generated {len(all_tracks)} test tracks")
    print(f"📍 Saved to: {output_file}")
    print("\nTrack summary:")
    print(f"  - Simple tracks: {len(generate_simple_tracks())}")
    print(f"  - Building encirclement: {len(generate_building_encirclement_tracks())}")
    print(f"  - Canal/river two-banks: {len(generate_canal_river_tracks())}")

    return all_tracks


def generate_txt_for_manual_entry():
    """Generate a human-readable format for manual entry into Firestore if needed."""
    all_tracks = (
        generate_simple_tracks()
        + generate_building_encirclement_tracks()
        + generate_canal_river_tracks()
    )

    output_file = Path(
        "/Users/geoffreytrambolho/Code/urbink/scripts/paris/test_tracks.txt"
    )
    with open(output_file, "w") as f:
        for track in all_tracks:
            f.write(f"\n{'='*60}\n")
            f.write(f"ID: {track['id']}\n")
            f.write(f"Name: {track['name']}\n")
            f.write(f"Type: {track['type']}\n")
            if "description" in track:
                f.write(f"Description: {track['description']}\n")
            f.write(f"Coordinates ({len(track['coordinates'])} points):\n")
            for i, coord in enumerate(track["coordinates"]):
                f.write(f"  {i+1}. {coord}\n")

    print(f"📝 Human-readable format: {output_file}")


if __name__ == "__main__":
    save_tracks_to_firebase_json()
    generate_txt_for_manual_entry()
