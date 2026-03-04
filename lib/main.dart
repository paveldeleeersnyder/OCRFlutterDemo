import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
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

class FlutterDocumentScanner extends StatefulWidget {
  const FlutterDocumentScanner({super.key});

  @override
  State<FlutterDocumentScanner> createState() => _FlutterDocumentScannerState();
}

class _FlutterDocumentScannerState extends State<FlutterDocumentScanner> {
  var pdf;

  Future<void> scanDocumentAsPdf() async {
    try {
      final result = await FlutterDocScanner().getScannedDocumentAsPdf(page: 40);
      if (result == null) {
        print('User cancelled');
        return;
      }
      setState(() {
        pdf = result.pdfUri;
      });
      print('PDF: ${result.pdfUri} (${result.pageCount} pages)');
    } on DocScanException catch (e) {
      print('Scan failed: ${e.code} - ${e.message}');
    }
  }

  Future<void> uploadPdf(pdf) async {
    setState(() {
      pdf = pdf;
    });
    final file = File(pdf);
    final _ = await Supabase.instance.client
      .storage
      .from('quotes') // TODO: put document in user folder
      .upload(pdf, file);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          ElevatedButton(onPressed: () => scanDocumentAsPdf(), child: const Text("Click here to scan document")),
          SizedBox(height: 10,),
          Container(
            height: 500,
            width: 250,
            child: pdf == null ?
            const Text("No image taken yet")
            : Text("Placeholder for PDF preview coming")
          )
        ],
      ),
    );
  }
}