// Package onmonumentproximity implements the Cloud Function triggered when a
// monument_proximity_events document is created by the Flutter client.
//
// Trigger: Firestore onCreate on /users/{userId}/monument_proximity_events/{eventId}
//
// Actions:
//  1. Reads monumentId, monumentName, monumentEmoji from the event document
//  2. Checks whether /users/{userId}/badges/monument_{monumentId} already exists
//  3. If not: creates the badge document and sends a FCM push notification
//  4. If already unlocked: no-op (idempotent)
package onmonumentproximity

import (
	"context"
	"fmt"
	"log"
	"strings"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ProximityEventDocument mirrors the Firestore document written by the Flutter client.
type ProximityEventDocument struct {
	MonumentId    string `firestore:"monumentId"`
	MonumentName  string `firestore:"monumentName"`
	MonumentEmoji string `firestore:"monumentEmoji"`
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

// badgeChecker abstracts Firestore reads/writes — allows mocking in tests.
type badgeChecker interface {
	readEvent(ctx context.Context, userId, eventId string) (ProximityEventDocument, error)
	badgeExists(ctx context.Context, userId, badgeId string) (bool, error)
	writeBadge(ctx context.Context, userId string, event ProximityEventDocument) error
	readFCMToken(ctx context.Context, userId string) (string, bool, error)
}

// messageSender abstracts FCM sends — allows mocking in tests.
type messageSender interface {
	send(ctx context.Context, msg *messaging.Message) error
}

// OnMonumentProximity is the Cloud Function entry point.
//
// Registered in firebase.json as a Firestore onCreate trigger on:
//
//	/users/{userId}/monument_proximity_events/{eventId}
func OnMonumentProximity(ctx context.Context, event FirestoreEvent) error {
	userId, eventId, err := parseEventResource(event.Value.Name)
	if err != nil {
		return err
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

	return process(ctx, userId, eventId,
		&firestoreChecker{fs: fsClient},
		&fcmSender{mc: msgClient},
	)
}

// parseEventResource extracts userId and eventId from the Firestore resource path.
func parseEventResource(resourceName string) (userId, eventId string, err error) {
	parts := strings.Split(resourceName, "/")
	if len(parts) < 4 {
		return "", "", fmt.Errorf("unexpected resource name: %s", resourceName)
	}
	return parts[len(parts)-3], parts[len(parts)-1], nil
}

// process is the core handler — fully testable via injected interfaces.
func process(ctx context.Context, userId, eventId string, checker badgeChecker, sender messageSender) error {
	event, err := checker.readEvent(ctx, userId, eventId)
	if err != nil {
		return fmt.Errorf("readEvent: %w", err)
	}

	badgeId := "monument_" + event.MonumentId
	exists, err := checker.badgeExists(ctx, userId, badgeId)
	if err != nil {
		return fmt.Errorf("badgeExists: %w", err)
	}
	if exists {
		log.Printf("badge %s already unlocked for user %s — skipping", badgeId, userId)
		return nil
	}

	if err := checker.writeBadge(ctx, userId, event); err != nil {
		return fmt.Errorf("writeBadge: %w", err)
	}

	token, ok, err := checker.readFCMToken(ctx, userId)
	if err != nil {
		log.Printf("readFCMToken error (non-fatal): %v", err)
		return nil
	}
	if !ok {
		log.Printf("no FCM token for user %s — skipping notification", userId)
		return nil
	}

	if err := sender.send(ctx, buildFCMMessage(token, event)); err != nil {
		return fmt.Errorf("messaging Send: %w", err)
	}

	log.Printf("badge monument_%s unlocked + notification sent to user %s", event.MonumentId, userId)
	return nil
}

// buildFCMMessage constructs the FCM payload for a monument badge unlock.
func buildFCMMessage(token string, event ProximityEventDocument) *messaging.Message {
	emoji := event.MonumentEmoji
	if emoji == "" {
		emoji = "🏛️"
	}
	return &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: fmt.Sprintf("%s Badge débloqué : %s !", emoji, event.MonumentName),
			Body:  "Tu es passé à proximité d'un monument emblématique — ouvre l'app pour le découvrir.",
		},
		Data: map[string]string{
			"type":        "monument_badge",
			"monumentId":  event.MonumentId,
			"badgeId":     "monument_" + event.MonumentId,
			"name":        event.MonumentName,
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

// ---------------------------------------------------------------------------
// Firestore implementation
// ---------------------------------------------------------------------------

type firestoreChecker struct{ fs *firestore.Client }

func (c *firestoreChecker) readEvent(ctx context.Context, userId, eventId string) (ProximityEventDocument, error) {
	snap, err := c.fs.Collection("users").Doc(userId).
		Collection("monument_proximity_events").Doc(eventId).Get(ctx)
	if err != nil {
		return ProximityEventDocument{}, err
	}
	var ev ProximityEventDocument
	if err := snap.DataTo(&ev); err != nil {
		return ProximityEventDocument{}, err
	}
	return ev, nil
}

func (c *firestoreChecker) badgeExists(ctx context.Context, userId, badgeId string) (bool, error) {
	_, err := c.fs.Collection("users").Doc(userId).Collection("badges").Doc(badgeId).Get(ctx)
	if err != nil {
		if status.Code(err) == codes.NotFound {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

func (c *firestoreChecker) writeBadge(ctx context.Context, userId string, event ProximityEventDocument) error {
	badgeId := "monument_" + event.MonumentId
	emoji := event.MonumentEmoji
	if emoji == "" {
		emoji = "🏛️"
	}
	_, err := c.fs.Collection("users").Doc(userId).Collection("badges").Doc(badgeId).Set(ctx, map[string]any{
		"monumentId":  event.MonumentId,
		"name":        event.MonumentName,
		"emoji":       emoji,
		"unlockedAt":  firestore.ServerTimestamp,
		"type":        "monument",
	})
	return err
}

func (c *firestoreChecker) readFCMToken(ctx context.Context, userId string) (string, bool, error) {
	snap, err := c.fs.Doc(fmt.Sprintf("users/%s", userId)).Get(ctx)
	if err != nil {
		return "", false, err
	}
	token, ok := snap.Data()["fcmToken"].(string)
	return token, ok && token != "", nil
}

// ---------------------------------------------------------------------------
// FCM implementation
// ---------------------------------------------------------------------------

type fcmSender struct{ mc *messaging.Client }

func (s *fcmSender) send(ctx context.Context, msg *messaging.Message) error {
	_, err := s.mc.Send(ctx, msg)
	return err
}

func intPtr(i int) *int { return &i }
