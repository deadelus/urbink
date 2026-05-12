// Package generateparcours implements the HTTP Cloud Function that generates
// an automatic walking/cycling circuit for a user.
//
// Trigger: HTTP POST /generateParcours
//
// Request body (JSON):
//
//	{ "lat": float64, "lng": float64, "durationMinutes": int, "mode": string }
//
// Authorization: Bearer <Firebase ID token> — userId extracted from verified token.
//
// Response body (JSON):
//
//	{ "name": string, "points": [{lat,lng}], "estimatedDistance": float64,
//	  "estimatedDuration": int, "mode": string, "type": "auto", "newStreetsCount": int }
//
// Algorithm: generates a closed circular circuit of N equidistant waypoints
// centered on the user's position, sized so that walking/cycling the full loop
// matches the requested duration.
package generateparcours

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"strings"
	"time"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
)

// Request is the JSON body expected from the Flutter client.
type Request struct {
	Lat             float64 `json:"lat"`
	Lng             float64 `json:"lng"`
	DurationMinutes int     `json:"durationMinutes"`
	Mode            string  `json:"mode"`
}

// Response is the JSON body returned to the Flutter client.
type Response struct {
	Name              string     `json:"name"`
	Points            []LatLng   `json:"points"`
	EstimatedDistance float64    `json:"estimatedDistance"`
	EstimatedDuration int        `json:"estimatedDuration"`
	Mode              string     `json:"mode"`
	Type              string     `json:"type"`
	NewStreetsCount   int        `json:"newStreetsCount"`
	CreatedAt         time.Time  `json:"createdAt"`
}

// LatLng is a GPS coordinate pair.
type LatLng struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

// tokenVerifier abstracts Firebase Auth token verification — allows mocking in tests.
type tokenVerifier interface {
	verifyIDToken(ctx context.Context, token string) (*auth.Token, error)
}

// speedMPerMin returns walking/cycling/driving speed in metres per minute.
func speedMPerMin(mode string) float64 {
	switch mode {
	case "bike":
		return 250 // ~15 km/h
	case "car":
		return 500 // ~30 km/h
	default: // "walk"
		return 83 // ~5 km/h
	}
}

// circuitPoints generates N equidistant waypoints on a circle of the given
// radius (metres) centered at (centerLat, centerLng). The first and last
// points are the same so the circuit closes.
func circuitPoints(centerLat, centerLng, radiusM float64) []LatLng {
	const n = 8
	// Convert radius from metres to degrees.
	// 1 degree latitude ≈ 111,000 m (constant).
	// 1 degree longitude ≈ 111,000 m × cos(lat).
	latDeg := radiusM / 111_000.0
	lngDeg := radiusM / (111_000.0 * math.Cos(centerLat*math.Pi/180))

	pts := make([]LatLng, n+1) // +1 to close the loop
	for i := 0; i <= n; i++ {
		angle := 2 * math.Pi * float64(i) / float64(n)
		pts[i] = LatLng{
			Lat: centerLat + latDeg*math.Sin(angle),
			Lng: centerLng + lngDeg*math.Cos(angle),
		}
	}
	return pts
}

// generateCircuit builds a Response for the given parameters without any I/O.
// This is the pure core of the algorithm — fully testable.
func generateCircuit(userId string, req Request) Response {
	speed := speedMPerMin(req.Mode)
	totalDistM := speed * float64(req.DurationMinutes)
	radiusM := totalDistM / (2 * math.Pi)

	if radiusM < 50 {
		radiusM = 50
	}

	mode := req.Mode
	if mode == "" {
		mode = "walk"
	}

	pts := circuitPoints(req.Lat, req.Lng, radiusM)

	// Estimate new streets: assume ~70 % of the route is unexplored,
	// one street segment every 120 m.
	newStreetsCount := int(totalDistM * 0.70 / 120)
	if newStreetsCount < 1 {
		newStreetsCount = 1
	}

	return Response{
		Name:              circuitName(req.DurationMinutes, mode),
		Points:            pts,
		EstimatedDistance: math.Round(totalDistM),
		EstimatedDuration: req.DurationMinutes * 60,
		Mode:              mode,
		Type:              "auto",
		NewStreetsCount:   newStreetsCount,
		CreatedAt:         time.Now().UTC(),
	}
}

// circuitName returns a human-readable name for the generated parcours.
func circuitName(durationMin int, mode string) string {
	modeLabel := map[string]string{
		"walk": "à pied",
		"bike": "à vélo",
		"car":  "en voiture",
	}
	label, ok := modeLabel[mode]
	if !ok {
		label = "à pied"
	}
	return fmt.Sprintf("Circuit %d min %s", durationMin, label)
}

// process handles the request with injectable dependencies.
func process(ctx context.Context, w http.ResponseWriter, r *http.Request, verifier tokenVerifier) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Extract Bearer token.
	authHeader := r.Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")
	if token == "" || token == authHeader {
		http.Error(w, "missing authorization token", http.StatusUnauthorized)
		return
	}

	// Verify token — extract userId.
	authToken, err := verifier.verifyIDToken(ctx, token)
	if err != nil {
		http.Error(w, "invalid token", http.StatusUnauthorized)
		return
	}
	userId := authToken.UID

	// Parse request body.
	var req Request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	// Validate required fields.
	if req.DurationMinutes <= 0 || req.DurationMinutes > 180 {
		http.Error(w, "durationMinutes must be between 1 and 180", http.StatusBadRequest)
		return
	}
	if req.Mode == "" {
		req.Mode = "walk"
	}

	resp := generateCircuit(userId, req)

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "encoding error", http.StatusInternalServerError)
	}
}

// ---------------------------------------------------------------------------
// Production entry point
// ---------------------------------------------------------------------------

// GenerateParcours is the Firebase Cloud Function entry point (HTTP trigger).
func GenerateParcours(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		http.Error(w, fmt.Sprintf("firebase.NewApp: %v", err), http.StatusInternalServerError)
		return
	}

	authClient, err := app.Auth(ctx)
	if err != nil {
		http.Error(w, fmt.Sprintf("app.Auth: %v", err), http.StatusInternalServerError)
		return
	}

	process(ctx, w, r, &firebaseVerifier{client: authClient})
}

// ---------------------------------------------------------------------------
// Firebase Auth implementation
// ---------------------------------------------------------------------------

type firebaseVerifier struct{ client *auth.Client }

func (v *firebaseVerifier) verifyIDToken(ctx context.Context, token string) (*auth.Token, error) {
	return v.client.VerifyIDToken(ctx, token)
}
