import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ditt Demokrati!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ditt Demokrati'),
    );
  }
}

/// A card widget for displaying a voting item with real‑time vote counting.
class VotingCard extends StatelessWidget {
  /// Unique identifier for this voting question.
  final String questionId;

  /// The title of the voting item.
  final String title;

  /// The description of the voting item.
  final String description;

  const VotingCard({
    super.key,
    required this.questionId,
    required this.title,
    required this.description,
  });

  /// Updates the vote count for the given option using a Firebase transaction.
  Future<void> _vote(String option) async {
    // Votes are stored under 'votes/<questionId>/<option>'
    final DatabaseReference voteRef = FirebaseDatabase.instance.ref(
      'votes/$questionId/$option',
    );
    try {
      await voteRef.runTransaction((currentVotes) {
        return (currentVotes as int? ?? 0) + 1;
      });
    } catch (e) {
      print("Error updating vote for $option: $e");
    }
  }

  /// Returns a stream of vote counts (as a Map) for this question.
  Stream<Map<String, int>> getVoteStream() {
    final DatabaseReference questionRef = FirebaseDatabase.instance.ref(
      'votes/$questionId',
    );
    return questionRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return {};
      final Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
      // Convert the dynamic values to int, using 0 if null.
      return map.map((key, value) => MapEntry(key, (value as int? ?? 0)));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define card dimensions and button width.
    const double minCardWidth = 300.0;
    const double maxCardWidth = 500.0;
    const double cardHeight = 300.0; // Increased to display vote counts.
    const double minButtonWidth = 80.0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth.clamp(minCardWidth, maxCardWidth);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title and description.
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Real-time vote count display.
              StreamBuilder<Map<String, int>>(
                stream: getVoteStream(),
                builder: (context, snapshot) {
                  int yesVotes = 0, noVotes = 0, blankVotes = 0, totalVotes = 0;
                  if (snapshot.hasData) {
                    yesVotes = snapshot.data!['yes'] ?? 0;
                    noVotes = snapshot.data!['no'] ?? 0;
                    blankVotes = snapshot.data!['blank'] ?? 0;
                    totalVotes = yesVotes + noVotes + blankVotes;
                  }
                  String formatPercentage(int votes) {
                    double pct =
                        totalVotes > 0 ? (votes / totalVotes * 100) : 0;
                    return pct.toStringAsFixed(1);
                  }

                  return Column(
                    children: [
                      Text("Total votes: $totalVotes"),
                      Text("Yes: $yesVotes (${formatPercentage(yesVotes)}%)"),
                      Text("No: $noVotes (${formatPercentage(noVotes)}%)"),
                      Text(
                        "Blank: $blankVotes (${formatPercentage(blankVotes)}%)",
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Vote buttons.
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 55, 156, 55),
                      minimumSize: const Size(minButtonWidth, 40),
                    ),
                    onPressed: () {
                      _vote('yes');
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 209, 47, 47),
                      minimumSize: const Size(minButtonWidth, 40),
                    ),
                    onPressed: () {
                      _vote('no');
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 201, 200, 200),
                      minimumSize: const Size(minButtonWidth, 40),
                    ),
                    onPressed: () {
                      _vote('blank');
                    },
                    child: const Text('Blank'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // This counter is just an example; it's separate from vote counting.
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 46, 106),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 233, 246),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Three VotingCards for different questions.
              VotingCard(
                questionId: 'question1',
                title: 'Bør Norge bli medlem av EU?',
                description: 'Bør Norge søke EU medlemskap i 2025?',
              ),
              VotingCard(
                questionId: 'question2',
                title: 'Skal Norge innføre 6-timers arbeidsdag?',
                description: 'Skal Norge teste en 6-timers arbeidsdag i 2025?',
              ),
              VotingCard(
                questionId: 'question3',
                title: 'Bør Norge øke skatter for å finansiere helsetjenester?',
                description:
                    'Bør Norge øke skatter for bedre helsetjenester i 2025?',
              ),
              const SizedBox(height: 16),
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
