.PHONY: urbink seed emulator

urbink:
	@bash entrypoint.sh

seed:
	@python3 scripts/populate_test_sessions.py --env local

emulator:
	@firebase emulators:start --config firebase.json.local --only firestore,auth
