import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/item_orcamento.dart';

class PdfService {
  Future<Uint8List> gerarOrcamentoPdf(
      String cliente,
      double valorTotal,
      List<ItemOrcamento> itens,
      Map<String, dynamic> config
      ) async {
    final pdf = pw.Document();

    // Carrega a logo real dos assets
    final ByteData bytes = await rootBundle.load('assets/logo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();
    final pw.MemoryImage imagemLogo = pw.MemoryImage(byteList);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // MARCA D'ÁGUA DE AUTORIA (Discreta, fora da margem de impressão)
              pw.Positioned(
                bottom: -20,
                right: 0,
                child: pw.Text(
                  'Desenvolvido por Francisco Soares',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
                ),
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. CABEÇALHO (Logo à esquerda, Dados Emissor à direita)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 80,
                        height: 80,
                        child: pw.Image(imagemLogo),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('ORÇAMENTO', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                          pw.SizedBox(height: 5),
                          pw.Text('Data: ${DateTime.now().toIso8601String().split('T')[0]}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 25),

                  // 2. BLOCO DO CLIENTE (Destacado com fundo cinza)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Orçamento para:', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        pw.SizedBox(height: 4),
                        pw.Text(cliente, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // 3. TABELA DE ITENS (Com linhas zebradas)
                  pw.Table.fromTextArray(
                    headers: ['ITEM', 'SERVIÇO', 'QTD', 'VALOR UNIT', 'VALOR'],
                    data: itens.map((i) => [
                      (itens.indexOf(i) + 1).toString().padLeft(2, '0'),
                      i.descricao,
                      i.quantidade.toString(),
                      'R\$ ${i.valorUnitario.toStringAsFixed(2)}',
                      'R\$ ${i.valorTotal.toStringAsFixed(2)}'
                    ]).toList(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                    // Alterna a cor das linhas para facilitar a leitura
                    rowDecoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))
                    ),
                    cellAlignment: pw.Alignment.centerLeft,
                    cellAlignments: {
                      0: pw.Alignment.center,
                      2: pw.Alignment.center,
                      3: pw.Alignment.centerRight,
                      4: pw.Alignment.centerRight,
                    },
                    cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  ),

                  pw.SizedBox(height: 20),

                  // 4. VALOR TOTAL (Em destaque)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text('VALOR TOTAL: ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        'R\$ ${valorTotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // 5. RODAPÉ (Centralizado com dados da configuração)
                  pw.Divider(color: PdfColors.grey400, thickness: 1),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(config['nome_empresa'] ?? 'Sua Empresa', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('CNPJ: ${config['cnpj'] ?? ''}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                        pw.SizedBox(height: 5),
                        pw.Text(config['responsavel'] ?? '', style: pw.TextStyle(fontSize: 12)),
                        pw.Text(config['email'] ?? '', style: pw.TextStyle(fontSize: 10)),
                        pw.Text(config['telefone'] ?? '', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}