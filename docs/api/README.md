# Références API externes

## Nominatim (snap to road)

- **Endpoint :** `https://nominatim.openstreetmap.org/`
- **Usage dans Urbink :** `shared/utils/nominatim_client.dart`
- **Rate limit :** 1 req/s — respecté via queue interne
- **Politique :** User-Agent obligatoire (`Urbink/1.0`)
- **Docs officielles :** https://nominatim.org/release-docs/latest/api/Overview/

## Firebase

| Service | Usage |
|---------|-------|
| Auth | Anonymous + Email/Apple/Google |
| Firestore | Source de vérité (structure dans `architecture.md`) |
| Storage | Photos pins, avatars |
| FCM | Push notifications |
| Cloud Functions | Go — logique serveur |

## OpenStreetMap

- **Tuiles :** `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- **Politique :** tile usage policy — max 2 req/s par IP
