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
