import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class FlutterDocumentScanner extends StatefulWidget {
  const FlutterDocumentScanner({super.key});

  @override
  State<FlutterDocumentScanner> createState() => _FlutterDocumentScannerState();
}

class _FlutterDocumentScannerState extends State<FlutterDocumentScanner> {
  var pdf;
  var uploaded = false;

  Future<void> scanDocumentAsPdf() async {
    try {
      final result = await FlutterDocScanner().getScannedDocumentAsPdf(page: 40);
      if (result == null) {
        print('User cancelled');
        return;
      }
      setState(() {
        pdf = result.pdfUri.replaceAll("file://", "");
        uploaded = false;
      });
      print('PDF: ${result.pdfUri} (${result.pageCount} pages)');
    } on DocScanException catch (e) {
      print('Scan failed: ${e.code} - ${e.message}');
    }
  }

  Future<String> uploadPdf() async {
    final file = File(pdf);
    var userId = dotenv.env['MOCK_USER_ID'] ?? '';
    var path = "$userId/quote-${"${Uuid().v4()}"}.pdf";
    final _ = await Supabase.instance.client
      .storage
      .from('quotes')
      .upload(path, file);

    return path;
  }

  void processDocument() async {
    var file_path = await uploadPdf();
    var api_url = dotenv.env['PROCESSING_API_URL'] ?? '';

    http.post(
      Uri.parse(api_url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'pdf': file_path}),
    );

    setState(() {
        uploaded = true;
    });
  }

  Future<void> previewPdf(path) async {
    File file = File(path);
    final Uint8List bytes = await file.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'offerte.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          ElevatedButton(onPressed: () => scanDocumentAsPdf(), child: const Text("Click here to scan document")),
          SizedBox(height: 10,),
          ((pdf == null) ? const Text("No image taken yet")
          : ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await previewPdf(pdf);
                  } catch (e) {
                    print("Could not preview pdf $e");
                  }
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Preview'),
              )),
          SizedBox(height: 10,),
          ElevatedButton(onPressed: ((pdf == null || uploaded) ? null : () => processDocument()), child: const Text("Process quote")),
          SizedBox(height: 10,),
          uploaded ? Text("submitted for processing") : SizedBox(height: 10,)
        ],
      ),
    );
  }
}