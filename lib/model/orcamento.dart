import 'dart:convert';
import 'item_orcamento.dart';

class Orcamento {
  int? id;
  String cliente;
  double valorTotal;
  String data;
  List<ItemOrcamento> itens;

  Orcamento({
    this.id,
    required this.cliente,
    required this.valorTotal,
    required this.data,
    required this.itens,
  });

  // Converte o objeto para o formato do banco de dados (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'valor_total': valorTotal,
      'data': data,
      // Transforma a lista de objetos direto em uma String JSON
      'itens': jsonEncode(itens.map((item) => item.toMap()).toList()),
    };
  }

  // Lógica para quando precisarmos buscar do banco no futuro
  factory Orcamento.fromMap(Map<String, dynamic> map) {
    // Transforma a String JSON de volta em uma lista de objetos
    var list = jsonDecode(map['itens']) as List;
    List<ItemOrcamento> listaItens = list.map((i) => ItemOrcamento.fromMap(i)).toList();

    return Orcamento(
      id: map['id'],
      cliente: map['cliente'],
      valorTotal: map['valor_total'],
      data: map['data'],
      itens: listaItens,
    );
  }
}