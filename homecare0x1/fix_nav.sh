#!/bin/bash

# Script to fix Firebase web build issues for homecare0x1 project

# Exit on error
set -e

# Backup files before modifying
echo "Backing up files..."
cp web/index.html web/index.html.bak-$(date +%F-%H%M%S)
cp pubspec.yaml pubspec.yaml.bak-$(date +%F-%H%M%S)
cp firebase.json firebase.json.bak-$(date +%F-%H%M%S)

# Step 1: Update web/index.html with Firebase JavaScript SDK
echo "Updating web/index.html..."
cat > web/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A new Flutter project.">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="homecare0x1">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>homecare0x1</title>
  <link rel="manifest" href="manifest.json">
  <!-- Firebase JavaScript SDK -->
  <script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js"></script>
  <script>
    // Replace with your Firebase configuration from Firebase Console
    const firebaseConfig = {
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "arandomtestproject",
      storageBucket: "YOUR_STORAGE_BUCKET",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID"
    };
    firebase.initializeApp(firebaseConfig);
  </script>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
EOF

# Step 2: Update pubspec.yaml with aligned dependencies
echo "Updating pubspec.yaml..."
cat > pubspec.yaml << 'EOF'
name: homecare0x1
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  permission_handler: ^11.3.1
  intl: ^0.19.0
  table_calendar: ^3.0.0
  uuid: ^4.5.1
  firebase_core: ^2.32.0
  firebase_auth: ^4.16.0
  firebase_auth_web: ^5.8.15
  cloud_firestore: ^4.17.5
  js: ^0.6.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

# Step 3: Update firebase.json with hosting settings
echo "Updating firebase.json..."
cat > firebase.json << 'EOF'
{
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "arandomtestproject",
          "appId": "1:312607240262:android:c00d42d0cf942885cf5a47",
          "fileOutput": "android/app/google-services.json"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "arandomtestproject",
          "configurations": {
            "android": "1:312607240262:android:c00d42d0cf942885cf5a47",
            "web": "YOUR_WEB_APP_ID"
          }
        }
      }
    }
  },
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
EOF

# Step 4: Clean and rebuild
echo "Cleaning and rebuilding project..."
flutter clean
flutter pub get

# Step 5: Run the project
echo "Running flutter run -d chrome -v..."
flutter run -d chrome -v

echo "Script completed. Please update web/index.html with your Firebase configuration (apiKey, authDomain, etc.) from Firebase Console."
echo "Backups of modified files are saved with timestamp suffixes."