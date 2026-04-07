import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    print('FlutterError: ${details.exception}');
  };
  runApp(const Lottery3DApp());
}
