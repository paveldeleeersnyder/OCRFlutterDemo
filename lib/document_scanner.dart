import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

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
        pdf = result.pdfUri.replaceAll("file://", "");
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
          Container(
            height: 500,
            width: 250,
            child: pdf == null ?
            const Text("No image taken yet")
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
              )
          )
        ],
      ),
    );
  }
}