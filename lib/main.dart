import 'package:flutter/material.dart';
import 'app.dart';
import 'widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Lottery3DAppWrapper());
}

class Lottery3DAppWrapper extends StatefulWidget {
  const Lottery3DAppWrapper({super.key});

  @override
  State<Lottery3DAppWrapper> createState() => _Lottery3DAppWrapperState();
}

class _Lottery3DAppWrapperState extends State<Lottery3DAppWrapper> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen(onFinished: () => setState(() => _showSplash = false)));
    }
    return const Lottery3DApp();
  }
}
