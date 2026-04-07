import 'package:flutter/material.dart';
import 'dart:async';
import 'app.dart';
import 'widgets/splash_screen.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };
    runApp(const Lottery3DAppWrapper());
  }, (error, stack) {
    print('Unhandled error: $error');
    print('Stack: $stack');
  });
}

class Lottery3DAppWrapper extends StatefulWidget {
  const Lottery3DAppWrapper({super.key});

  @override
  State<Lottery3DAppWrapper> createState() => _Lottery3DAppWrapperState();
}

class _Lottery3DAppWrapperState extends State<Lottery3DAppWrapper> {
  bool _showSplash = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('应用启动失败', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_errorMessage, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _hasError = false;
                      _showSplash = true;
                    }),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_showSplash) {
      return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen(onFinished: () => setState(() => _showSplash = false)));
    }
    return const Lottery3DApp();
  }
}
