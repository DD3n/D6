#!/bin/bash
# update_project.sh (for Flutter Firebase integration)
# This script updates your Flutter project by:
# 1. Adding/Updating firebase_core and firebase_database dependencies in pubspec.yaml.
# 2. Creating a new file lib/vote_tally_widget.dart with the vote tally widget code.
# 3. Updating lib/main.dart to initialize Firebase using firebase_options.dart and integrate the VoteTallyWidget.
#
# IMPORTANT:
# - Review the changes after running this script.
# - Run "flutter pub get" to update dependencies.
# - Run "flutterfire configure" to generate firebase_options.dart if you haven't done so.
#
# Run this script from the root of your Flutter project:
#   bash update_project.sh

set -e

# Step 0: Verify required files
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: pubspec.yaml not found. Are you in the root of a Flutter project?"
  exit 1
fi

if [ ! -f "lib/main.dart" ]; then
  echo "Error: lib/main.dart not found. Aborting."
  exit 1
fi

# Create backups for pubspec.yaml and lib/main.dart
cp pubspec.yaml pubspec.yaml.bak
echo "Backup of pubspec.yaml created as pubspec.yaml.bak"
cp lib/main.dart lib/main.dart.bak
echo "Backup of lib/main.dart created as lib/main.dart.bak"

###########################
# Step 1: Update pubspec.yaml dependencies
###########################
# Update firebase_core dependency
if ! grep -q "firebase_core:" pubspec.yaml; then
  sed -i '/dependencies:/a\
  firebase_core: ^2.20.0' pubspec.yaml
  echo "Added firebase_core dependency to pubspec.yaml."
else
  echo "firebase_core dependency already present; ensure its version is updated if needed."
fi

# Update firebase_database dependency
if ! grep -q "firebase_database:" pubspec.yaml; then
  sed -i '/dependencies:/a\
  firebase_database: ^10.0.0' pubspec.yaml
  echo "Added firebase_database dependency to pubspec.yaml."
else
  echo "firebase_database dependency already present; ensure its version is updated if needed."
fi

###########################
# Step 2: Create lib/vote_tally_widget.dart
###########################
if [ ! -d "lib" ]; then
  echo "Error: lib directory not found."
  exit 1
fi

if [ ! -f "lib/vote_tally_widget.dart" ]; then
cat << 'EOF' > lib/vote_tally_widget.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VoteTallyWidget extends StatefulWidget {
  const VoteTallyWidget({Key? key}) : super(key: key);

  @override
  _VoteTallyWidgetState createState() => _VoteTallyWidgetState();
}

class _VoteTallyWidgetState extends State<VoteTallyWidget> {
  bool showTally = false;
  int yes = 0;
  int no = 0;
  int blank = 0;

  late DatabaseReference voteRef;

  @override
  void initState() {
    super.initState();
    // Get a reference to the "votes" node in the Realtime Database.
    voteRef = FirebaseDatabase.instance.ref('votes');
    voteRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        setState(() {
          yes = data['yes'] ?? 0;
          no = data['no'] ?? 0;
          blank = data['blank'] ?? 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int total = yes + no + blank;
    int yesPercent = total > 0 ? (yes * 100 ~/ total) : 0;
    int noPercent = total > 0 ? (no * 100 ~/ total) : 0;
    int blankPercent = total > 0 ? (blank * 100 ~/ total) : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              showTally = !showTally;
            });
          },
          child: const Text("Show Vote Tally"),
        ),
        if (showTally)
          Column(
            children: [
              Text("Yes $yes ($yesPercent%)"),
              Text("No $no ($noPercent%)"),
              Text("Blank $blank ($blankPercent%)"),
            ],
          ),
      ],
    );
  }
}
EOF
  echo "Created lib/vote_tally_widget.dart with VoteTallyWidget code."
else
  echo "lib/vote_tally_widget.dart already exists; skipping creation."
fi

###########################
# Step 3: Update lib/main.dart for Firebase initialization and widget integration
###########################
MAIN_FILE="lib/main.dart"

# Insert import for firebase_options.dart if not present.
if ! grep -q "import 'firebase_options.dart';" "$MAIN_FILE"; then
  sed -i "1iimport 'firebase_options.dart';" "$MAIN_FILE"
  echo "Added import for firebase_options.dart in main.dart."
else
  echo "Import for firebase_options.dart already present in main.dart; skipping."
fi

# Insert import for vote_tally_widget.dart if not present.
if ! grep -q "import 'vote_tally_widget.dart';" "$MAIN_FILE"; then
  sed -i "1iimport 'vote_tally_widget.dart';" "$MAIN_FILE"
  echo "Added import for vote_tally_widget.dart in main.dart."
else
  echo "Import for vote_tally_widget.dart already exists in main.dart; skipping."
fi

# Insert Firebase initialization in main.dart if not already present.
if ! grep -q "Firebase.initializeApp(options:" "$MAIN_FILE"; then
  # Replace "void main() {" with an async main() that initializes Firebase.
  sed -i 's/void main() {/void main() async {\n  WidgetsFlutterBinding.ensureInitialized();\n  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);\n/' "$MAIN_FILE"
  echo "Inserted Firebase initialization in main.dart."
else
  echo "Firebase initialization already present in main.dart; skipping."
fi

# Insert VoteTallyWidget into the UI if not already present.
if ! grep -q "VoteTallyWidget(" "$MAIN_FILE"; then
  # Look for the Scaffold body and insert the VoteTallyWidget at the top of the body.
  sed -i 's/body:[[:space:]]*\(.*\),/body: Column(\n          mainAxisAlignment: MainAxisAlignment.center,\n          children: [\n            const VoteTallyWidget(),\n            \1\n          ],\n        ),/' "$MAIN_FILE"
  echo "Inserted VoteTallyWidget into the UI in main.dart."
else
  echo "VoteTallyWidget already in use in main.dart; skipping."
fi

echo "Project update completed successfully."
echo "IMPORTANT: Run 'flutter pub get' to update dependencies."
echo "Also, run 'flutterfire configure' to generate firebase_options.dart if you haven't already."
