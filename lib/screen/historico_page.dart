import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../model/orcamento.dart';
import '../service/pdf_service.dart';
import 'visualizacao_page.dart';

class HistoricoPage extends StatefulWidget {
  @override
  _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  final PdfService _pdfService = PdfService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Histórico'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: FutureBuilder<List<Orcamento>>(
        future: DatabaseHelper.instance.getOrcamentos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final lista = snapshot.data!;

          if (lista.isEmpty) return Center(child: Text('Nenhum orçamento salvo.'));

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final orc = lista[index];
              return Dismissible(
                key: Key(orc.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await DatabaseHelper.instance.deleteOrcamento(orc.id!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excluído com sucesso')));
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(orc.cliente, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('R\$ ${orc.valorTotal.toStringAsFixed(2)} - ${orc.data.split('T')[0]}'),
                    trailing: Icon(Icons.picture_as_pdf, color: Colors.red),
                    onTap: () async {
                      final config = await DatabaseHelper.instance.getConfiguracao();
                      final pdfBytes = await _pdfService.gerarOrcamentoPdf(orc.cliente, orc.valorTotal, orc.itens, config);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => VisualizacaoPage(pdfBytes: pdfBytes, nomeArquivo: 'orcamento_${orc.cliente}.pdf'),
                      ));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}