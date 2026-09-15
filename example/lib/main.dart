import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';

void main() {
  runApp(
    EdgeGuard(
      config: const EdgeGuardConfig(
        enableDebugOverlay: true,
        enableInspector: true,
      ),
      child: const EdgeGuardInspector(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edge Guard Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edge Guard Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Welcome to the EdgeGuard example! Open the Inspector (bug icon) to view active edge-to-edge constraints.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BottomActionDemo()),
              );
            },
            child: const Text('Bottom Action Demo'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const KeyboardDemo()));
            },
            child: const Text('Keyboard Demo'),
          ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const EdgeGuardBottomSheet(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('This bottom sheet is protected by EdgeGuard!'),
                  ),
                ),
              );
            },
            child: const Text('Bottom Sheet Demo'),
          ),
        ],
      ),
    );
  }
}

class BottomActionDemo extends StatelessWidget {
  const BottomActionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Action')),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text('Content goes here...'))),
          Container(
            color: Colors.deepPurple.shade50,
            width: double.infinity,
            child: EdgeGuardBottomAction(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Safe Submit Button'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeyboardDemo extends StatelessWidget {
  const KeyboardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard / IME')),
      body: Column(
        children: [
          const Expanded(
            child: Center(child: Text('Tap the field to open the keyboard.')),
          ),
          Container(
            color: Colors.deepPurple.shade50,
            child: EdgeGuardBottomAction(
              padding: const EdgeInsets.all(16),
              child: const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter text here',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
