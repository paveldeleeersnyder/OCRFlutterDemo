import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './document_scanner.dart'; 

void main() async {
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['PUBLIC_SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['PUBLIC_SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Demo for scanning documents in flutter."),
        ),
        body: Center(
          child: FlutterDocumentScanner(),
        ),
      ),
    );
  }
}