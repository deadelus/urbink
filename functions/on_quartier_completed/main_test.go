package onquartiercompleted

import (
	"context"
	"errors"
	"strings"
	"testing"

	"firebase.google.com/go/v4/messaging"
)

// --- Mock implementations ---

type mockReader struct {
	badge    BadgeDocument
	badgeErr error
	token    string
	tokenOk  bool
	tokenErr error
}

func (m *mockReader) readBadge(_ context.Context, _, _ string) (BadgeDocument, error) {
	return m.badge, m.badgeErr
}

func (m *mockReader) readFCMToken(_ context.Context, _ string) (string, bool, error) {
	return m.token, m.tokenOk, m.tokenErr
}

type mockSender struct {
	sent    []*messaging.Message
	sendErr error
}

func (m *mockSender) send(_ context.Context, msg *messaging.Message) error {
	if m.sendErr != nil {
		return m.sendErr
	}
	m.sent = append(m.sent, msg)
	return nil
}

// --- parseEventResource ---

func TestParseEventResource(t *testing.T) {
	tests := []struct {
		name         string
		resourceName string
		wantUserId   string
		wantBadgeId  string
		wantErr      bool
	}{
		{
			name:         "quartier badge",
			resourceName: "projects/p/databases/d/documents/users/uid123/badges/quartier_marais",
			wantUserId:   "uid123",
			wantBadgeId:  "quartier_marais",
		},
		{
			name:         "non-quartier badge is skipped",
			resourceName: "projects/p/databases/d/documents/users/uid123/badges/monument_eiffel",
			wantUserId:   "",
			wantBadgeId:  "",
		},
		{
			name:         "malformed path",
			resourceName: "short/path",
			wantErr:      true,
		},
		{
			name:         "empty string",
			resourceName: "",
			wantErr:      true,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			userId, badgeId, err := parseEventResource(tc.resourceName)
			if tc.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if userId != tc.wantUserId {
				t.Errorf("userId: got %q, want %q", userId, tc.wantUserId)
			}
			if badgeId != tc.wantBadgeId {
				t.Errorf("badgeId: got %q, want %q", badgeId, tc.wantBadgeId)
			}
		})
	}
}

// --- buildFCMMessage ---

func TestBuildFCMMessage(t *testing.T) {
	badge := BadgeDocument{
		QuartierId:  "marais",
		Name:        "Le Marais",
		SecretLocal: "La fontaine cachée rue de Bretagne",
	}
	msg := buildFCMMessage("tok123", badge)

	if msg.Token != "tok123" {
		t.Errorf("token: got %q, want %q", msg.Token, "tok123")
	}
	if !strings.Contains(msg.Notification.Title, "Le Marais") {
		t.Errorf("title %q should contain badge name", msg.Notification.Title)
	}
	if msg.Data["quartierId"] != "marais" {
		t.Errorf("data quartierId: got %q", msg.Data["quartierId"])
	}
	if msg.Data["type"] != "quartier_completed" {
		t.Errorf("data type: got %q", msg.Data["type"])
	}
	if msg.Data["name"] != "Le Marais" {
		t.Errorf("data name: got %q", msg.Data["name"])
	}
	if msg.APNS == nil || msg.APNS.Payload == nil || msg.APNS.Payload.Aps == nil {
		t.Fatal("APNS config missing")
	}
}

// --- process ---

func TestProcess_HappyPath(t *testing.T) {
	reader := &mockReader{
		badge:   BadgeDocument{QuartierId: "marais", Name: "Le Marais"},
		token:   "fcm-token-xyz",
		tokenOk: true,
	}
	sender := &mockSender{}

	if err := process(context.Background(), "uid1", "quartier_marais", reader, sender); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(sender.sent) != 1 {
		t.Fatalf("expected 1 message sent, got %d", len(sender.sent))
	}
	if sender.sent[0].Token != "fcm-token-xyz" {
		t.Errorf("wrong FCM token in sent message")
	}
	if !strings.Contains(sender.sent[0].Notification.Title, "Le Marais") {
		t.Errorf("notification title should contain quartier name")
	}
}

func TestProcess_NoFCMToken(t *testing.T) {
	reader := &mockReader{
		badge:   BadgeDocument{Name: "Le Marais"},
		token:   "",
		tokenOk: false,
	}
	sender := &mockSender{}

	if err := process(context.Background(), "uid1", "quartier_marais", reader, sender); err != nil {
		t.Fatalf("no-token should be non-fatal, got: %v", err)
	}
	if len(sender.sent) != 0 {
		t.Errorf("expected no message when no FCM token")
	}
}

func TestProcess_BadgeReadError(t *testing.T) {
	reader := &mockReader{badgeErr: errors.New("firestore unavailable")}
	sender := &mockSender{}

	if err := process(context.Background(), "uid1", "quartier_marais", reader, sender); err == nil {
		t.Fatal("expected error when badge read fails")
	}
}

func TestProcess_FCMTokenReadError_NonFatal(t *testing.T) {
	reader := &mockReader{
		badge:    BadgeDocument{Name: "Le Marais"},
		tokenErr: errors.New("timeout"),
	}
	sender := &mockSender{}

	// token read error is logged but non-fatal
	if err := process(context.Background(), "uid1", "quartier_marais", reader, sender); err != nil {
		t.Fatalf("token read error should be non-fatal, got: %v", err)
	}
	if len(sender.sent) != 0 {
		t.Errorf("expected no message when token read fails")
	}
}

func TestProcess_FCMSendError(t *testing.T) {
	reader := &mockReader{
		badge:   BadgeDocument{Name: "Le Marais"},
		token:   "tok",
		tokenOk: true,
	}
	sender := &mockSender{sendErr: errors.New("FCM quota exceeded")}

	if err := process(context.Background(), "uid1", "quartier_marais", reader, sender); err == nil {
		t.Fatal("expected error when FCM send fails")
	}
}
