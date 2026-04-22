import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/item_orcamento.dart';

class PdfService {
  // Agora recebe os 3 parâmetros corretamente
  Future<File> gerarOrcamentoPdf(String cliente, double valorTotal, List<ItemOrcamento> itens) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // LOGO DO FLUTTER CENTRALIZADA
              pw.Center(
                child: pw.FlutterLogo(size: 80),
              ),
              pw.SizedBox(height: 20),

              // CABEÇALHO
              pw.Center(
                child: pw.Text('ORÇAMENTO COMERCIAL', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),

              // DADOS DO CLIENTE
              pw.Text('Dados do Cliente', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('Nome: $cliente', style: pw.TextStyle(fontSize: 14)),
              pw.Text('Data da Emissão: ${DateTime.now().toIso8601String().split('T')[0]}', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // TABELA DE ITENS (Omissão corrigida)
              pw.Text('Itens do Orçamento', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
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
                cellPadding: const pw.EdgeInsets.all(8),
              ),

              pw.SizedBox(height: 30),

              // TOTAL GERAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('VALOR TOTAL: ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('R\$ ${valorTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, color: PdfColors.green800, fontWeight: pw.FontWeight.bold)),
                ],
              ),

              pw.Spacer(), // Empurra o rodapé para o fim da página

              // RODAPÉ
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
    final file = File('${directory.path}/orcamento_${cliente.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}