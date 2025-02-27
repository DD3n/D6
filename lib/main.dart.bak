import 'package:flutter/material.dart';

void main() {
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

/// Represents a card for displaying a voting item.
class VotingCard extends StatelessWidget {
  /// The title of the voting item.
  final String title;

  /// The description of the voting item.
  final String description;

  /// Creates a [VotingCard].
  const VotingCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    // Define minimum and maximum widths for the card
    const double minCardWidth = 300.0; // Minimum width for small screens
    const double maxCardWidth = 500.0; // Maximum width for large screens
    const double cardHeight = 200.0; // Consistent height for all cards

    // Calculate the card width based on screen size, constrained by min and max
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth.clamp(minCardWidth, maxCardWidth);

    // Define a minimum button width
    const double minButtonWidth = 80.0;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Vertically center content
            crossAxisAlignment:
                CrossAxisAlignment.center, // Horizontally center content
            children: [
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
                      // Handle "Yes" button press
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
                      // Handle "No" button press
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
                      // Handle "Blank" button press
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
        backgroundColor: Colors.blue[900],
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 233, 246),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const VotingCard(
                title: 'Bør Norge bli medlem av EU?',
                description: 'Bør Norge søke EU medlemskap i 2025?.',
              ),
              const VotingCard(
                title: 'Skal Norge innføre 6-timers arbeidsdag?',
                description: 'Skal Norge teste en 6-timers arbeidsdag i 2025?.',
              ),
              const VotingCard(
                title: 'Bør Norge øke skatter for å finansiere helsetjenester?',
                description:
                    'Bør Norge øke skatter for bedre helsetjenester i 2025?.',
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
