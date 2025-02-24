import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

/// A simple model representing a BankID user.
class BankIDUser {
  final String id;
  final String name;
  BankIDUser({required this.id, required this.name});
}

/// Dummy function to simulate a BankID sign-in process for testing purposes.
///
/// The optional parameter [shouldFail] allows you to simulate a failure (for testing error handling).
/// In production, replace this with real API integration per BankID's developer guidelines.
Future<BankIDUser> signInWithBankID({bool shouldFail = false}) async {
  print("Initiating dummy BankID sign-in...");
  await Future.delayed(const Duration(seconds: 2));
  if (shouldFail) {
    print("Simulated BankID sign-in failure.");
    throw Exception("Simulated BankID sign-in failure");
  }
  final dummyUser = BankIDUser(id: "bankid_12345", name: "Test BankID User");
  print("Dummy BankID sign-in successful: ${dummyUser.name}");
  return dummyUser;
}

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BankIDUser? _bankIDUser;
  int _counter = 0;

  Future<void> _handleBankIDSignIn() async {
    try {
      BankIDUser user = await signInWithBankID();
      setState(() {
        _bankIDUser = user;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signed in as ${user.name}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('BankID Sign-In Failed')));
    }
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: <Widget>[
              // Debug container to ensure the sign-in button is visible.
              Container(
                color: Colors.yellow.shade100,
                padding: const EdgeInsets.all(8.0),
                child:
                    _bankIDUser == null
                        ? ElevatedButton(
                          onPressed: _handleBankIDSignIn,
                          child: const Text('Sign in with BankID'),
                        )
                        : Text(
                          'Signed in as: ${_bankIDUser!.name}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 24),
              // Voting cards – pass the current BankID user.
              VotingCard(
                questionId: 'question1',
                title: 'Bør Norge bli medlem av EU?',
                description: 'Bør Norge søke EU medlemskap i 2025?',
                bankIDUser: _bankIDUser,
              ),
              VotingCard(
                questionId: 'question2',
                title: 'Skal Norge innføre 6-timers arbeidsdag?',
                description: 'Skal Norge teste en 6-timers arbeidsdag i 2025?',
                bankIDUser: _bankIDUser,
              ),
              VotingCard(
                questionId: 'question3',
                title: 'Bør Norge øke skatter for å finansiere helsetjenester?',
                description:
                    'Bør Norge øke skatter for bedre helsetjenester i 2025?',
                bankIDUser: _bankIDUser,
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

/// A card widget that displays a voting item, allows voting (if the user is signed in via BankID),
/// and shows real-time vote totals and the user's selected option.
class VotingCard extends StatefulWidget {
  final String questionId;
  final String title;
  final String description;
  final BankIDUser? bankIDUser;

  const VotingCard({
    super.key,
    required this.questionId,
    required this.title,
    required this.description,
    required this.bankIDUser,
  });

  @override
  State<VotingCard> createState() => _VotingCardState();
}

class _VotingCardState extends State<VotingCard> {
  String? _selectedOption;

  Future<void> _vote(String option) async {
    if (widget.bankIDUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in with BankID to vote')),
      );
      return;
    }

    final DatabaseReference voteRef = FirebaseDatabase.instance.ref(
      'votes/${widget.questionId}/$option',
    );
    try {
      await voteRef.runTransaction((TransactionMutableData mutableData) async {
        int currentVotes = mutableData.value as int? ?? 0;
        mutableData.value = currentVotes + 1;
        return Transaction.success(mutableData);
      });
      setState(() {
        _selectedOption = option;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You voted: ${option.toUpperCase()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error voting for ${option.toUpperCase()}')),
      );
    }
  }

  Stream<Map<String, int>> getVoteStream() {
    final DatabaseReference questionRef = FirebaseDatabase.instance.ref(
      'votes/${widget.questionId}',
    );
    return questionRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return {};
      final Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
      return map.map((key, value) => MapEntry(key, (value as int? ?? 0)));
    });
  }

  @override
  Widget build(BuildContext context) {
    const double minCardWidth = 300.0;
    const double maxCardWidth = 500.0;
    const double cardHeight = 340.0;
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
            children: [
              Text(
                widget.title,
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
                widget.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Your Vote: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _selectedOption != null
                        ? _selectedOption!.toUpperCase()
                        : "None",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _selectedOption != null ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                    onPressed: () => _vote('yes'),
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
                    onPressed: () => _vote('no'),
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
                    onPressed: () => _vote('blank'),
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
