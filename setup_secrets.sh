FAILED=false

if [ -z "${FIREBASE_SERVER_KEY}" ]; then
  FAILED=true
fi

sed -i '' "s|{FIREBASE_SERVER_KEY}|${FIREBASE_SERVER_KEY}|g" "TogglWatch WatchKit Extension/Secrets.plist"

if [ "$FAILED" = true ]; then
  exit 1
fi

echo "All env secrets found!"
