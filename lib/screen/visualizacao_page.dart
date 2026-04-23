import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class VisualizacaoPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String nomeArquivo;

  VisualizacaoPage({required this.pdfBytes, required this.nomeArquivo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Orçamento')), // Corrigido de app_bar para appBar
      body: PdfPreview(
        build: (format) => pdfBytes,
        pdfFileName: nomeArquivo, // Corrigido de fileName para pdfFileName
        canChangePageFormat: false,
        actions: [
          PdfPreviewAction(
            icon: Icon(Icons.save_alt),
            onPressed: (context, build, format) async {
              // Abre a janela nativa de salvamento do Android
              await Printing.sharePdf(bytes: pdfBytes, filename: nomeArquivo);
            },
          ),
        ],
      ),
    );
  }
}