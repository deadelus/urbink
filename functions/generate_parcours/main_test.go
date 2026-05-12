package generateparcours

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"math"
	"net/http"
	"net/http/httptest"
	"testing"

	"firebase.google.com/go/v4/auth"
)

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

type mockVerifier struct {
	uid string
	err error
}

func (m *mockVerifier) verifyIDToken(_ context.Context, _ string) (*auth.Token, error) {
	if m.err != nil {
		return nil, m.err
	}
	return &auth.Token{UID: m.uid}, nil
}

// ---------------------------------------------------------------------------
// speedMPerMin
// ---------------------------------------------------------------------------

func TestSpeedMPerMin(t *testing.T) {
	tests := []struct {
		mode  string
		wantM float64
	}{
		{"walk", 83},
		{"bike", 250},
		{"car", 500},
		{"", 83},
		{"unknown", 83},
	}
	for _, tc := range tests {
		got := speedMPerMin(tc.mode)
		if got != tc.wantM {
			t.Errorf("speedMPerMin(%q) = %v, want %v", tc.mode, got, tc.wantM)
		}
	}
}

// ---------------------------------------------------------------------------
// circuitPoints
// ---------------------------------------------------------------------------

func TestCircuitPoints_Count(t *testing.T) {
	pts := circuitPoints(48.8566, 2.3522, 200)
	// N+1 points to close the loop
	if len(pts) != 9 {
		t.Fatalf("want 9 points (8+close), got %d", len(pts))
	}
}

func TestCircuitPoints_Closes(t *testing.T) {
	pts := circuitPoints(48.8566, 2.3522, 200)
	first, last := pts[0], pts[len(pts)-1]
	if math.Abs(first.Lat-last.Lat) > 1e-10 || math.Abs(first.Lng-last.Lng) > 1e-10 {
		t.Errorf("circuit not closed: first=%v, last=%v", first, last)
	}
}

func TestCircuitPoints_DistanceApprox(t *testing.T) {
	// Waypoints should be roughly at the requested radius from center.
	centerLat, centerLng := 48.8566, 2.3522
	radiusM := 300.0
	pts := circuitPoints(centerLat, centerLng, radiusM)

	for i, p := range pts[:len(pts)-1] {
		// Approximate distance in metres using lat/lng deltas.
		dlat := (p.Lat - centerLat) * 111_000
		dlng := (p.Lng - centerLng) * 111_000 * math.Cos(centerLat*math.Pi/180)
		dist := math.Sqrt(dlat*dlat + dlng*dlng)
		if math.Abs(dist-radiusM) > 10 { // 10m tolerance
			t.Errorf("point %d: distance from center = %.1f m, want %.1f m ±10", i, dist, radiusM)
		}
	}
}

// ---------------------------------------------------------------------------
// generateCircuit
// ---------------------------------------------------------------------------

func TestGenerateCircuit_Modes(t *testing.T) {
	tests := []struct {
		mode          string
		durationMin   int
		wantDistRange [2]float64 // [min, max]
	}{
		{"walk", 30, [2]float64{2000, 3000}},  // 83m/min × 30 ≈ 2490m
		{"bike", 30, [2]float64{6000, 9000}},  // 250m/min × 30 = 7500m
		{"car", 15, [2]float64{5000, 9000}},   // 500m/min × 15 = 7500m
	}
	for _, tc := range tests {
		r := generateCircuit("uid1", Request{
			Lat: 48.8566, Lng: 2.3522,
			DurationMinutes: tc.durationMin, Mode: tc.mode,
		})
		if r.EstimatedDistance < tc.wantDistRange[0] || r.EstimatedDistance > tc.wantDistRange[1] {
			t.Errorf("mode=%q dur=%d: distance=%.0f, want [%.0f, %.0f]",
				tc.mode, tc.durationMin, r.EstimatedDistance, tc.wantDistRange[0], tc.wantDistRange[1])
		}
		if r.EstimatedDuration != tc.durationMin*60 {
			t.Errorf("mode=%q: estimatedDuration=%d, want %d", tc.mode, r.EstimatedDuration, tc.durationMin*60)
		}
		if r.Type != "auto" {
			t.Errorf("type=%q, want 'auto'", r.Type)
		}
		if r.Mode != tc.mode {
			t.Errorf("mode=%q, want %q", r.Mode, tc.mode)
		}
		if len(r.Points) != 9 {
			t.Errorf("points=%d, want 9", len(r.Points))
		}
	}
}

func TestGenerateCircuit_NewStreetsCount(t *testing.T) {
	r := generateCircuit("uid1", Request{
		Lat: 48.8566, Lng: 2.3522,
		DurationMinutes: 30, Mode: "walk",
	})
	if r.NewStreetsCount < 1 {
		t.Errorf("newStreetsCount=%d, want >= 1", r.NewStreetsCount)
	}
}

func TestGenerateCircuit_EmptyModeDefaultsToWalk(t *testing.T) {
	r := generateCircuit("uid1", Request{
		Lat: 48.8566, Lng: 2.3522,
		DurationMinutes: 15, Mode: "",
	})
	if r.Mode != "walk" {
		t.Errorf("mode=%q, want 'walk'", r.Mode)
	}
}

func TestGenerateCircuit_MinRadius(t *testing.T) {
	// Very short duration → radius should not go below 50m.
	r := generateCircuit("uid1", Request{
		Lat: 48.8566, Lng: 2.3522,
		DurationMinutes: 1, Mode: "walk",
	})
	if len(r.Points) == 0 {
		t.Fatal("expected points for 1-minute circuit")
	}
}

// ---------------------------------------------------------------------------
// circuitName
// ---------------------------------------------------------------------------

func TestCircuitName(t *testing.T) {
	tests := []struct {
		dur  int
		mode string
		want string
	}{
		{30, "walk", "Circuit 30 min à pied"},
		{45, "bike", "Circuit 45 min à vélo"},
		{60, "car", "Circuit 60 min en voiture"},
		{15, "unknown", "Circuit 15 min à pied"},
	}
	for _, tc := range tests {
		got := circuitName(tc.dur, tc.mode)
		if got != tc.want {
			t.Errorf("circuitName(%d, %q) = %q, want %q", tc.dur, tc.mode, got, tc.want)
		}
	}
}

// ---------------------------------------------------------------------------
// process (HTTP handler — integration-style)
// ---------------------------------------------------------------------------

func post(t *testing.T, body Request, token string) (*httptest.ResponseRecorder, *http.Request) {
	t.Helper()
	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/generateParcours", bytes.NewReader(b))
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	return rr, req
}

func TestProcess_OK(t *testing.T) {
	verifier := &mockVerifier{uid: "user123"}
	rr, req := post(t, Request{Lat: 48.8566, Lng: 2.3522, DurationMinutes: 30, Mode: "walk"}, "valid-token")
	process(req.Context(), rr, req, verifier)

	if rr.Code != http.StatusOK {
		t.Fatalf("status=%d, want 200; body=%s", rr.Code, rr.Body.String())
	}

	var resp Response
	if err := json.Unmarshal(rr.Body.Bytes(), &resp); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if resp.Type != "auto" {
		t.Errorf("type=%q, want 'auto'", resp.Type)
	}
	if len(resp.Points) != 9 {
		t.Errorf("points=%d, want 9", len(resp.Points))
	}
}

func TestProcess_MissingToken(t *testing.T) {
	verifier := &mockVerifier{uid: "user123"}
	rr, req := post(t, Request{Lat: 48.8566, Lng: 2.3522, DurationMinutes: 30, Mode: "walk"}, "")
	process(req.Context(), rr, req, verifier)

	if rr.Code != http.StatusUnauthorized {
		t.Errorf("status=%d, want 401", rr.Code)
	}
}

func TestProcess_InvalidToken(t *testing.T) {
	verifier := &mockVerifier{err: errors.New("invalid")}
	rr, req := post(t, Request{Lat: 48.8566, Lng: 2.3522, DurationMinutes: 30, Mode: "walk"}, "bad-token")
	process(req.Context(), rr, req, verifier)

	if rr.Code != http.StatusUnauthorized {
		t.Errorf("status=%d, want 401", rr.Code)
	}
}

func TestProcess_InvalidDuration(t *testing.T) {
	verifier := &mockVerifier{uid: "user123"}
	tests := []int{0, -5, 200}
	for _, dur := range tests {
		rr, req := post(t, Request{Lat: 48.8566, Lng: 2.3522, DurationMinutes: dur, Mode: "walk"}, "valid-token")
		process(req.Context(), rr, req, verifier)
		if rr.Code != http.StatusBadRequest {
			t.Errorf("duration=%d: status=%d, want 400", dur, rr.Code)
		}
	}
}

func TestProcess_MethodNotAllowed(t *testing.T) {
	verifier := &mockVerifier{uid: "user123"}
	req := httptest.NewRequest(http.MethodGet, "/generateParcours", nil)
	req.Header.Set("Authorization", "Bearer token")
	rr := httptest.NewRecorder()
	process(req.Context(), rr, req, verifier)
	if rr.Code != http.StatusMethodNotAllowed {
		t.Errorf("status=%d, want 405", rr.Code)
	}
}

func TestProcess_DefaultModeWalk(t *testing.T) {
	verifier := &mockVerifier{uid: "user123"}
	rr, req := post(t, Request{Lat: 48.8566, Lng: 2.3522, DurationMinutes: 30, Mode: ""}, "valid-token")
	process(req.Context(), rr, req, verifier)

	if rr.Code != http.StatusOK {
		t.Fatalf("status=%d", rr.Code)
	}
	var resp Response
	json.Unmarshal(rr.Body.Bytes(), &resp)
	if resp.Mode != "walk" {
		t.Errorf("mode=%q, want 'walk'", resp.Mode)
	}
}


