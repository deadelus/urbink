// Package onquartiercompleted implements the Cloud Function triggered when a
// quartier badge is created in Firestore.
//
// Trigger: Firestore onCreate on /users/{userId}/badges/{badgeId}
// where badgeId starts with "quartier_"
//
// Actions:
//  1. Reads the FCM token from the `fcmToken` field of /users/{userId}
//  2. Sends a push notification via FCM
//
// The badge document is written by the Flutter client on completion detection.
// This function's sole responsibility is the push notification (FCM) side,
// which Story 10.2 will extend with full notification preferences.
package onquartiercompleted

import (
	"context"
	"fmt"
	"log"
	"strings"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
)

// BadgeDocument mirrors the Firestore badge document written by the Flutter app.
type BadgeDocument struct {
	QuartierId  string `firestore:"quartierId"`
	Name        string `firestore:"name"`
	SecretLocal string `firestore:"secretLocal"`
}

// FirestoreEvent is the event payload passed to the Firestore trigger.
type FirestoreEvent struct {
	OldValue   FirestoreValue `json:"oldValue"`
	Value      FirestoreValue `json:"value"`
	UpdateMask struct {
		FieldPaths []string `json:"fieldPaths"`
	} `json:"updateMask"`
}

// FirestoreValue wraps the document data.
type FirestoreValue struct {
	Name   string         `json:"name"`
	Fields map[string]any `json:"fields"`
}

// badgeReader abstracts Firestore reads — allows mocking in tests.
type badgeReader interface {
	readBadge(ctx context.Context, userId, badgeId string) (BadgeDocument, error)
	readFCMToken(ctx context.Context, userId string) (string, bool, error)
}

// messageSender abstracts FCM sends — allows mocking in tests.
type messageSender interface {
	send(ctx context.Context, msg *messaging.Message) error
}

// OnQuartierCompleted is the Cloud Function entry point.
//
// Registered in firebase.json as a Firestore onCreate trigger on:
//
//	/users/{userId}/badges/{badgeId}
//
// Only processes documents where badgeId starts with "quartier_".
func OnQuartierCompleted(ctx context.Context, event FirestoreEvent) error {
	userId, badgeId, err := parseEventResource(event.Value.Name)
	if err != nil {
		return err
	}
	if badgeId == "" {
		return nil // non-quartier badge — skip silently
	}

	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		return fmt.Errorf("firebase.NewApp: %w", err)
	}

	fsClient, err := app.Firestore(ctx)
	if err != nil {
		return fmt.Errorf("app.Firestore: %w", err)
	}
	defer fsClient.Close()

	msgClient, err := app.Messaging(ctx)
	if err != nil {
		return fmt.Errorf("app.Messaging: %w", err)
	}

	return process(ctx, userId, badgeId,
		&firestoreReader{fs: fsClient},
		&fcmSender{mc: msgClient},
	)
}

// parseEventResource extracts userId and badgeId from the Firestore resource path.
// Returns empty badgeId (no error) when the badge is not a quartier badge.
func parseEventResource(resourceName string) (userId, badgeId string, err error) {
	parts := strings.Split(resourceName, "/")
	if len(parts) < 4 {
		return "", "", fmt.Errorf("unexpected resource name: %s", resourceName)
	}
	bid := parts[len(parts)-1]
	if !strings.HasPrefix(bid, "quartier_") {
		return "", "", nil
	}
	return parts[len(parts)-3], bid, nil
}

// process is the core handler — fully testable via injected interfaces.
func process(ctx context.Context, userId, badgeId string, reader badgeReader, sender messageSender) error {
	badge, err := reader.readBadge(ctx, userId, badgeId)
	if err != nil {
		return fmt.Errorf("badge Get: %w", err)
	}

	token, ok, err := reader.readFCMToken(ctx, userId)
	if err != nil {
		log.Printf("user Get error (non-fatal): %v", err)
		return nil
	}
	if !ok {
		log.Printf("no FCM token for user %s — skipping notification", userId)
		return nil
	}

	if err := sender.send(ctx, buildFCMMessage(token, badge)); err != nil {
		return fmt.Errorf("messaging Send: %w", err)
	}

	log.Printf("notification sent to user %s for quartier %s", userId, badge.Name)
	return nil
}

// buildFCMMessage constructs the FCM payload for a quartier completion.
func buildFCMMessage(token string, badge BadgeDocument) *messaging.Message {
	return &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: fmt.Sprintf("🏆 Quartier %s complété !", badge.Name),
			Body:  "Secret local révélé — ouvre l'app pour le découvrir.",
		},
		Data: map[string]string{
			"type":       "quartier_completed",
			"quartierId": badge.QuartierId,
			"name":       badge.Name,
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound: "default",
					Badge: intPtr(1),
				},
			},
		},
	}
}

// firestoreReader implements badgeReader against a real Firestore client.
type firestoreReader struct{ fs *firestore.Client }

func (r *firestoreReader) readBadge(ctx context.Context, userId, badgeId string) (BadgeDocument, error) {
	snap, err := r.fs.Collection("users").Doc(userId).Collection("badges").Doc(badgeId).Get(ctx)
	if err != nil {
		return BadgeDocument{}, err
	}
	var badge BadgeDocument
	if err := snap.DataTo(&badge); err != nil {
		return BadgeDocument{}, err
	}
	return badge, nil
}

func (r *firestoreReader) readFCMToken(ctx context.Context, userId string) (string, bool, error) {
	snap, err := r.fs.Doc(fmt.Sprintf("users/%s", userId)).Get(ctx)
	if err != nil {
		return "", false, err
	}
	token, ok := snap.Data()["fcmToken"].(string)
	return token, ok && token != "", nil
}

// fcmSender implements messageSender against a real FCM client.
type fcmSender struct{ mc *messaging.Client }

func (s *fcmSender) send(ctx context.Context, msg *messaging.Message) error {
	_, err := s.mc.Send(ctx, msg)
	return err
}

func intPtr(i int) *int { return &i }
