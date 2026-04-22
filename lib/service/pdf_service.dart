import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/orcamento.dart';

class PdfService {
  Future<File> gerarOrcamentoPdf(Orcamento orcamento) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Orçamento Comercial', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Dados do Cliente', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Nome: ${orcamento.cliente}', style: pw.TextStyle(fontSize: 14)),
              pw.Text('Data da Emissão: ${orcamento.data.split('T')[0]}', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Valor Total Estimado:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('R\$ ${orcamento.valor.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, color: PdfColors.green800)),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Paragraph(
                text: 'Este orçamento tem validade de 15 dias corridos a partir da data de emissão acima. '
                    'Valores sujeitos a alteração caso haja mudança no escopo dos serviços.',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          );
        },
      ),
    );


    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/orcamento_${orcamento.cliente.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}