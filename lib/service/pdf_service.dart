import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/item_orcamento.dart';

class PdfService {
  // Alterado para retornar Uint8List (bytes do PDF)
  Future<Uint8List> gerarOrcamentoPdf(String cliente, double valorTotal, List<ItemOrcamento> itens) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.SizedBox(
                  width: 80,
                  height: 80,
                  child: pw.FlutterLogo(),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('ORÇAMENTO COMERCIAL', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Nome: $cliente', style: pw.TextStyle(fontSize: 14)),
              pw.Text('Data: ${DateTime.now().toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Tabela de Itens
              pw.Table.fromTextArray(
                headers: ['Descrição', 'Qtd', 'Unitário', 'Total'],
                data: itens.map((item) => [
                  item.descricao,
                  item.quantidade.toString(),
                  'R\$ ${item.valorUnitario.toStringAsFixed(2)}',
                  'R\$ ${item.valorTotal.toStringAsFixed(2)}',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellAlignment: pw.Alignment.centerLeft,
              ),

              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('TOTAL: R\$ ${valorTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save(); // Retorna os bytes brutos
  }
}