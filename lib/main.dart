import 'package:flutter/material.dart';
import 'dart:async';
import 'app.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const Lottery3DApp());
  }, (error, stack) {
    debugPrint('Unhandled error: $error');
  });
}
