package onmonumentproximity

import (
	"context"
	"errors"
	"testing"

	"firebase.google.com/go/v4/messaging"
)

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

type mockChecker struct {
	event       ProximityEventDocument
	eventErr    error
	exists      bool
	existsErr   error
	writeErr    error
	fcmToken    string
	hasFCMToken bool
	fcmErr      error
}

func (m *mockChecker) readEvent(_ context.Context, _, _ string) (ProximityEventDocument, error) {
	return m.event, m.eventErr
}

func (m *mockChecker) badgeExists(_ context.Context, _, _ string) (bool, error) {
	return m.exists, m.existsErr
}

func (m *mockChecker) writeBadge(_ context.Context, _ string, _ ProximityEventDocument) error {
	return m.writeErr
}

func (m *mockChecker) readFCMToken(_ context.Context, _ string) (string, bool, error) {
	return m.fcmToken, m.hasFCMToken, m.fcmErr
}

type mockSender struct {
	sent    []*messaging.Message
	sendErr error
}

func (s *mockSender) send(_ context.Context, msg *messaging.Message) error {
	s.sent = append(s.sent, msg)
	return s.sendErr
}

// ---------------------------------------------------------------------------
// parseEventResource
// ---------------------------------------------------------------------------

func TestParseEventResource(t *testing.T) {
	tests := []struct {
		name        string
		resource    string
		wantUserId  string
		wantEventId string
		wantErr     bool
	}{
		{
			name:        "chemin valide",
			resource:    "projects/p/databases/(default)/documents/users/uid123/monument_proximity_events/monument_tour-eiffel",
			wantUserId:  "uid123",
			wantEventId: "monument_tour-eiffel",
		},
		{
			name:    "chemin trop court",
			resource: "users/uid123",
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			userId, eventId, err := parseEventResource(tt.resource)
			if tt.wantErr {
				if err == nil {
					t.Fatal("attendu une erreur, aucune obtenue")
				}
				return
			}
			if err != nil {
				t.Fatalf("erreur inattendue: %v", err)
			}
			if userId != tt.wantUserId {
				t.Errorf("userId: got %q, want %q", userId, tt.wantUserId)
			}
			if eventId != tt.wantEventId {
				t.Errorf("eventId: got %q, want %q", eventId, tt.wantEventId)
			}
		})
	}
}

// ---------------------------------------------------------------------------
// process — cas nominaux
// ---------------------------------------------------------------------------

func TestProcess_BadgeNotExistsSendsFCM(t *testing.T) {
	checker := &mockChecker{
		event:       ProximityEventDocument{MonumentId: "tour-eiffel", MonumentName: "Tour Eiffel", MonumentEmoji: "🗼"},
		exists:      false,
		hasFCMToken: true,
		fcmToken:    "tok123",
	}
	sender := &mockSender{}

	err := process(context.Background(), "uid1", "monument_tour-eiffel", checker, sender)
	if err != nil {
		t.Fatalf("erreur inattendue: %v", err)
	}
	if len(sender.sent) != 1 {
		t.Fatalf("attendu 1 message FCM, got %d", len(sender.sent))
	}
	msg := sender.sent[0]
	if msg.Token != "tok123" {
		t.Errorf("token FCM: got %q, want %q", msg.Token, "tok123")
	}
}

func TestProcess_BadgeAlreadyExistsSkipsFCM(t *testing.T) {
	checker := &mockChecker{
		event:  ProximityEventDocument{MonumentId: "tour-eiffel", MonumentName: "Tour Eiffel"},
		exists: true,
	}
	sender := &mockSender{}

	err := process(context.Background(), "uid1", "monument_tour-eiffel", checker, sender)
	if err != nil {
		t.Fatalf("erreur inattendue: %v", err)
	}
	if len(sender.sent) != 0 {
		t.Fatalf("attendu 0 message FCM (badge déjà débloqué), got %d", len(sender.sent))
	}
}

func TestProcess_NoFCMTokenSkipsNotification(t *testing.T) {
	checker := &mockChecker{
		event:       ProximityEventDocument{MonumentId: "louvre", MonumentName: "Louvre"},
		exists:      false,
		hasFCMToken: false,
	}
	sender := &mockSender{}

	err := process(context.Background(), "uid1", "monument_louvre", checker, sender)
	if err != nil {
		t.Fatalf("erreur inattendue: %v", err)
	}
	if len(sender.sent) != 0 {
		t.Fatalf("attendu 0 message FCM (pas de token), got %d", len(sender.sent))
	}
}

func TestProcess_ReadEventError(t *testing.T) {
	checker := &mockChecker{
		eventErr: errors.New("firestore read error"),
	}
	sender := &mockSender{}

	err := process(context.Background(), "uid1", "monument_X", checker, sender)
	if err == nil {
		t.Fatal("attendu une erreur, aucune obtenue")
	}
}

func TestProcess_BadgeExistsCheckError(t *testing.T) {
	checker := &mockChecker{
		event:     ProximityEventDocument{MonumentId: "X"},
		existsErr: errors.New("firestore error"),
	}
	sender := &mockSender{}

	err := process(context.Background(), "uid1", "monument_X", checker, sender)
	if err == nil {
		t.Fatal("attendu une erreur sur badgeExists, aucune obtenue")
	}
}

func TestProcess_FCMErrorIsNonFatal(t *testing.T) {
	checker := &mockChecker{
		event:       ProximityEventDocument{MonumentId: "louvre", MonumentName: "Louvre", MonumentEmoji: "🏛️"},
		exists:      false,
		hasFCMToken: true,
		fcmToken:    "tok123",
	}
	sender := &mockSender{sendErr: errors.New("fcm unavailable")}

	// L'erreur FCM ne doit pas remonter — le badge est déjà créé
	err := process(context.Background(), "uid1", "monument_louvre", checker, sender)
	if err != nil {
		t.Fatalf("erreur FCM doit être non-fatale, got: %v", err)
	}
}

func TestProcess_WriteBadgeError(t *testing.T) {
	checker := &mockChecker{
		event:    ProximityEventDocument{MonumentId: "X"},
		exists:   false,
		writeErr: errors.New("write error"),
	}
	sender := &mockSender{}

	err := process(context.Background(), "uid1", "monument_X", checker, sender)
	if err == nil {
		t.Fatal("attendu une erreur sur writeBadge, aucune obtenue")
	}
}

// ---------------------------------------------------------------------------
// buildFCMMessage
// ---------------------------------------------------------------------------

func TestBuildFCMMessage_EmojiParDefaut(t *testing.T) {
	event := ProximityEventDocument{
		MonumentId:    "X",
		MonumentName:  "Monument inconnu",
		MonumentEmoji: "",
	}
	msg := buildFCMMessage("tok", event)
	if msg.Notification == nil {
		t.Fatal("notification nil")
	}
	// L'emoji par défaut 🏛️ doit être dans le titre
	if len(msg.Notification.Title) == 0 {
		t.Error("titre vide")
	}
	if msg.Data["badgeId"] != "monument_X" {
		t.Errorf("badgeId: got %q, want %q", msg.Data["badgeId"], "monument_X")
	}
}

func TestBuildFCMMessage_EmojiPersonnalise(t *testing.T) {
	event := ProximityEventDocument{
		MonumentId:    "tour-eiffel",
		MonumentName:  "Tour Eiffel",
		MonumentEmoji: "🗼",
	}
	msg := buildFCMMessage("tok123", event)
	if msg.Token != "tok123" {
		t.Errorf("token: got %q, want %q", msg.Token, "tok123")
	}
	if msg.Data["monumentId"] != "tour-eiffel" {
		t.Errorf("monumentId: got %q, want %q", msg.Data["monumentId"], "tour-eiffel")
	}
	if msg.Data["name"] != "Tour Eiffel" {
		t.Errorf("name: got %q, want %q", msg.Data["name"], "Tour Eiffel")
	}
}
