import 'package:flutter/material.dart';
import 'dart:async';
import 'app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      print('FlutterError: ${details.exception}');
      print('StackTrace: ${details.stack}');
    };
    runApp(const Lottery3DApp());
  }, (error, stack) {
    print('Unhandled async error: $error');
    print('StackTrace: $stack');
  });
}
