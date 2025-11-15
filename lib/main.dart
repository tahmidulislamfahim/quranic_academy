import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quranic_academy/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env (silently ignore if missing)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  runApp(const App());
}
