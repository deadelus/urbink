// Package onquartiercompleted implements the Cloud Function triggered when a
// quartier badge is created in Firestore.
//
// Trigger: Firestore onCreate on /users/{userId}/badges/{badgeId}
// where badgeId starts with "quartier_"
//
// Actions:
//  1. Reads FCM token from /users/{userId}/fcmToken
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
	Name   string                 `json:"name"`
	Fields map[string]interface{} `json:"fields"`
}

// OnQuartierCompleted is the Cloud Function entry point.
//
// Registered in firebase.json as a Firestore onCreate trigger on:
//
//	/users/{userId}/badges/{badgeId}
//
// Only processes documents where badgeId starts with "quartier_".
func OnQuartierCompleted(ctx context.Context, event FirestoreEvent) error {
	// Extract resource path: projects/.../databases/.../documents/users/{uid}/badges/{badgeId}
	resourceName := event.Value.Name
	parts := strings.Split(resourceName, "/")
	if len(parts) < 2 {
		return fmt.Errorf("unexpected resource name: %s", resourceName)
	}

	badgeId := parts[len(parts)-1]
	if !strings.HasPrefix(badgeId, "quartier_") {
		// Not a quartier badge — skip silently.
		return nil
	}
	userId := parts[len(parts)-3]

	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		return fmt.Errorf("firebase.NewApp: %w", err)
	}

	fsClient, err := app.Firestore(ctx)
	if err != nil {
		return fmt.Errorf("app.Firestore: %w", err)
	}
	defer fsClient.Close()

	// Read badge data.
	badgeRef := fsClient.Collection("users").Doc(userId).Collection("badges").Doc(badgeId)
	badgeSnap, err := badgeRef.Get(ctx)
	if err != nil {
		return fmt.Errorf("badge Get: %w", err)
	}
	var badge BadgeDocument
	if err := badgeSnap.DataTo(&badge); err != nil {
		return fmt.Errorf("DataTo badge: %w", err)
	}

	// Read FCM token.
	userRef := fsClient.Doc(fmt.Sprintf("users/%s", userId))
	userSnap, err := userRef.Get(ctx)
	if err != nil {
		log.Printf("user Get error (non-fatal): %v", err)
		return nil
	}
	fcmToken, ok := userSnap.Data()["fcmToken"].(string)
	if !ok || fcmToken == "" {
		log.Printf("no FCM token for user %s — skipping notification", userId)
		return nil
	}

	// Send FCM push notification.
	msgClient, err := app.Messaging(ctx)
	if err != nil {
		return fmt.Errorf("app.Messaging: %w", err)
	}

	msg := &messaging.Message{
		Token: fcmToken,
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

	if _, err := msgClient.Send(ctx, msg); err != nil {
		return fmt.Errorf("messaging Send: %w", err)
	}

	log.Printf("notification sent to user %s for quartier %s", userId, badge.Name)
	return nil
}

// writeQuartierCompletion is used in tests to pre-populate Firestore.
func writeQuartierCompletion(
	ctx context.Context,
	client *firestore.Client,
	userId, badgeId string,
	data BadgeDocument,
) error {
	_, err := client.Collection("users").Doc(userId).
		Collection("badges").Doc(badgeId).Set(ctx, data)
	return err
}

func intPtr(i int) *int { return &i }
