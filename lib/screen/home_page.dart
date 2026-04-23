import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/orcamento.dart';
import '../model/item_orcamento.dart';
import '../database/database_helper.dart';
import '../service/pdf_service.dart';
import 'visualizacao_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controladores do Cliente
  final _clienteController = TextEditingController();

  // Controladores do Novo Item
  final _descricaoController = TextEditingController();
  final _qtdController = TextEditingController();
  final _valorController = TextEditingController();

  final PdfService _pdfService = PdfService();
  bool _isProcessing = false;

  // Lista de itens na memória (para cálculo em tempo real)
  List<ItemOrcamento> _itens = [];

  // Getter para calcular o total geral dinamicamente
  double get totalGeral => _itens.fold(0, (sum, item) => sum + item.valorTotal);

  void _adicionarItem() {
    final descricao = _descricaoController.text.trim();
    final qtdTexto = _qtdController.text.trim();
    final valorTexto = _valorController.text.replaceAll(',', '.');

    if (descricao.isEmpty || qtdTexto.isEmpty || valorTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos do item.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final int? qtd = int.tryParse(qtdTexto);
    final double? valor = double.tryParse(valorTexto);

    if (qtd == null || valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantidade ou valor inválidos.'), backgroundColor: Colors.red),
      );
      return;
    }

    // Atualiza a tela com o novo item e recalcula o total
    setState(() {
      _itens.add(ItemOrcamento(
        descricao: descricao,
        quantidade: qtd,
        valorUnitario: valor,
      ));
    });

    // Limpa os campos do item para a próxima digitação
    _descricaoController.clear();
    _qtdController.clear();
    _valorController.clear();
  }

  void _removerItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  void _gerarESalvar() async {
    final nomeCliente = _clienteController.text.trim();

    if (nomeCliente.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe o nome do cliente.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicione pelo menos um item ao orçamento.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isProcessing = true; });

    try {
      final String itensJson = jsonEncode(_itens.map((item) => item.toMap()).toList());

      final mapOrcamento = {
        'cliente': nomeCliente,
        'valor_total': totalGeral,
        'data': DateTime.now().toIso8601String(),
        'itens': itensJson,
      };

      // Salva no banco
      final db = await DatabaseHelper.instance.database;
      await db.insert('orcamentos', mapOrcamento);

      // Gera os bytes do PDF (Não tem mais .path)
      final pdfBytes = await _pdfService.gerarOrcamentoPdf(nomeCliente, totalGeral, _itens);

      // Limpa a tela principal antes de navegar
      setState(() {
        _clienteController.clear();
        _itens.clear();
      });

      // Abre a tela de visualização enviando os bytes do PDF
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisualizacaoPage(
              pdfBytes: pdfBytes,
              nomeArquivo: 'orcamento_${nomeCliente.replaceAll(' ', '_')}.pdf',
            ),
          ),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao processar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isProcessing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Orçamento'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // CABEÇALHO DO CLIENTE E CADASTRO DE ITEM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _clienteController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Cliente',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 24),

                  // BOX DE ADICIONAR ITEM
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adicionar Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          TextField(
                            controller: _descricaoController,
                            decoration: InputDecoration(labelText: 'Descrição do Produto/Serviço', isDense: true),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _qtdController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Qtd', isDense: true),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _valorController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(labelText: 'Valor Unitário (R\$)', isDense: true),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _adicionarItem,
                              icon: Icon(Icons.add),
                              label: Text('Incluir na Lista'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // LISTA DE ITENS ADICIONADOS
                  Text('Itens do Orçamento:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _itens.isEmpty
                      ? Text('Nenhum item adicionado ainda.', style: TextStyle(color: Colors.grey))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _itens.length,
                    itemBuilder: (context, index) {
                      final item = _itens[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.descricao),
                        subtitle: Text('${item.quantidade}x R\$ ${item.valorUnitario.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('R\$ ${item.valorTotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // RODAPÉ COM TOTAL E BOTÃO DE SALVAR
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Geral:', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                    Text('R\$ ${totalGeral.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                    onPressed: _isProcessing ? null : _gerarESalvar,
                    child: _isProcessing
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Gerar PDF e Salvar', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _descricaoController.dispose();
    _qtdController.dispose();
    _valorController.dispose();
    super.dispose();
  }
}