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

    // Calculate the minimum width for buttons based on card width
    const double minButtonWidth =
        80.0; // Adjust this to fit "Blank" and ensure "Yes" and "No" are at least as wide

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: cardWidth, // Use calculated width, constrained by min and max
        height: cardHeight, // Ensure consistent height for all cards
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the content vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center the content horizontally
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center the title text
                maxLines: 2, // Allow title to wrap to two lines if needed
                overflow:
                    TextOverflow.ellipsis, // Handle overflow with ellipsis
              ),
              const SizedBox(
                height: 8,
              ), // Add spacing between title and description
              Text(
                description,
                textAlign: TextAlign.center, // Center the description text
                maxLines: 2, // Allow description to wrap to two lines if needed
                overflow:
                    TextOverflow.ellipsis, // Handle overflow with ellipsis
              ),
              const SizedBox(height: 16),
              // Use Wrap with dynamic direction based on screen width
              Wrap(
                spacing: 10, // Horizontal spacing between buttons
                runSpacing: 10, // Vertical spacing between rows
                alignment:
                    WrapAlignment.center, // Center the buttons horizontally
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        55,
                        156,
                        55,
                      ), // Light green color
                      minimumSize: const Size(
                        minButtonWidth,
                        40,
                      ), // Minimum width and height for consistency
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
                      backgroundColor: const Color.fromARGB(
                        255,
                        209,
                        47,
                        47,
                      ), // Red color
                      minimumSize: const Size(
                        minButtonWidth,
                        40,
                      ), // Minimum width and height for consistency
                    ),
                    onPressed: () {},
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        201,
                        200,
                        200,
                      ), // Darker grey color
                      minimumSize: const Size(
                        minButtonWidth,
                        40,
                      ), // Minimum width and height for consistency
                    ),
                    onPressed: () {},
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
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white, // White text color
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 233, 246),
      body: SingleChildScrollView(
        // Make the content scrollable to handle overflow
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              const SizedBox(height: 16), // Add spacing before the counter
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
