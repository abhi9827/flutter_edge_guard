import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';

void main() {
  runApp(
    EdgeGuard(
      config: const EdgeGuardConfig(
        enableDebugOverlay: false,
        enableInspector: false,
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
            'Welcome to the EdgeGuard example!\n\n'
            '🐛 = Toggle diagnostic report\n'
            '🎨 = Toggle visual zone overlay',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
          _DemoButton(
            label: 'Bottom Action Demo',
            subtitle: 'EdgeGuardBottomAction protects from nav bar',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BottomActionDemo()),
            ),
          ),
          _DemoButton(
            label: 'Animated Action Demo',
            subtitle: 'EdgeGuardAnimatedAction — smooth keyboard slide',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnimatedActionDemo()),
            ),
          ),
          _DemoButton(
            label: 'Keyboard Demo',
            subtitle: 'IME awareness and protection',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const KeyboardDemo()),
            ),
          ),
          _DemoButton(
            label: 'Bottom Sheet Demo',
            subtitle: 'EdgeGuardBottomSheet',
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => const EdgeGuardBottomSheet(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('This bottom sheet is protected by EdgeGuard!'),
                ),
              ),
            ),
          ),
          _DemoButton(
            label: 'Scrim Demo',
            subtitle: 'EdgeGuardScrim — gradient over system bars',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScrimDemo()),
            ),
          ),
          _DemoButton(
            label: 'Diagnostics Report',
            subtitle: 'View the full machine-readable report',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DiagnosticsDemo()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DemoButton({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ─── Bottom Action Demo ──────────────────────────────────────────────────────

class BottomActionDemo extends StatelessWidget {
  const BottomActionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Action')),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'The button below is protected by EdgeGuardBottomAction.\n'
                'It will never overlap the navigation bar or gesture area.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Container(
            color: Colors.deepPurple.shade50,
            width: double.infinity,
            child: EdgeGuardBottomAction(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
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

// ─── Animated Action Demo ────────────────────────────────────────────────────

class AnimatedActionDemo extends StatelessWidget {
  const AnimatedActionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Action')),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Tap the text field to open the keyboard.\n'
                'The button below will smoothly slide up with the keyboard.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type something…',
              ),
            ),
          ),
          Container(
            color: Colors.deepPurple.shade50,
            width: double.infinity,
            child: EdgeGuardAnimatedAction(
              padding: const EdgeInsets.all(16),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Animated Submit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Keyboard Demo ───────────────────────────────────────────────────────────

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

// ─── Scrim Demo ──────────────────────────────────────────────────────────────

class ScrimDemo extends StatelessWidget {
  const ScrimDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Colorful background that would normally clash with system bars.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              ),
            ),
            child: const Center(
              child: Text(
                'EdgeGuardScrim adds a subtle\ngradient over the system bars\nto ensure icon readability.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Scrim protects both top and bottom bars.
          const EdgeGuardScrim(
            edge: EdgeGuardScrimEdge.both,
            maxOpacity: 0.5,
          ),
          // Back button overlay
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top + 8,
            left: 8,
            child: BackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diagnostics Demo ────────────────────────────────────────────────────────

class DiagnosticsDemo extends StatelessWidget {
  const DiagnosticsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final report = EdgeGuardDiagnostics.tryInspect(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Report')),
      body: report == null
          ? const Center(child: Text('No EdgeGuard scope found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issues Found: ${report.issues.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...report.issues.map(
                    (issue) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          issue.severity == EdgeGuardSeverity.critical
                              ? Icons.error
                              : issue.severity == EdgeGuardSeverity.warning
                                  ? Icons.warning_amber
                                  : Icons.info_outline,
                          color: issue.severity == EdgeGuardSeverity.critical
                              ? Colors.red
                              : issue.severity == EdgeGuardSeverity.warning
                                  ? Colors.orange
                                  : Colors.blue,
                        ),
                        title: Text(issue.title),
                        subtitle: Text(issue.problem),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Raw JSON Report:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
