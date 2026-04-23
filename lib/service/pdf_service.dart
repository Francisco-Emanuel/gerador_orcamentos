import 'dart:typed_bytes';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/item_orcamento.dart';

class PdfService {
  Future<Uint8List> gerarOrcamentoPdf(String cliente, double valorTotal, List<ItemOrcamento> itens, Map<String, dynamic> config) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
              children: [
                // Marca d'água de autoria - Discreta
                pw.Positioned(bottom: 0, right: 0, child: pw.Text('Desenvolvido por Francisco Soares', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400))),

                // Marca d'água da logo - Transparente
                pw.Positioned.fill(child: pw.Center(child: pw.Opacity(opacity: 0.05, child: pw.FlutterLogo(size: 300)))),

                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Orçamento para: $cliente', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Divider(),
                      pw.SizedBox(height: 20),
                      pw.Table.fromTextArray(
                        headers: ['ITEM', 'SERVIÇO', 'QTD', 'UNIT', 'TOTAL'],
                        data: itens.map((i) => [itens.indexOf(i)+1, i.descricao, i.quantidade, i.valorUnitario, i.valorTotal]).toList(),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('VALOR TOTAL: R\$ ${valorTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Spacer(),
                      // Dados vindos das Configurações
                      pw.Divider(),
                      pw.Text(config['nome_empresa'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('CNPJ: ${config['cnpj']}'),
                      pw.Text('Resp: ${config['responsavel']}'),
                      pw.Text('E-mail: ${config['email']} | Tel: ${config['telefone']}'),
                    ]
                )
              ]
          );
        }
    ));
    return pdf.save();
  }
}