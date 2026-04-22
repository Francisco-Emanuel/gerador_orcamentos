import 'dart:convert';

class ItemOrcamento {
  String descricao;
  int quantidade;
  double valorUnitario;

  ItemOrcamento({
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
  });

  double get valorTotal => quantidade * valorUnitario;

  Map<String, dynamic> toMap() => {
    'descricao': descricao,
    'quantidade': quantidade,
    'valorUnitario': valorUnitario,
  };

  factory ItemOrcamento.fromMap(Map<String, dynamic> map) => ItemOrcamento(
    descricao: map['descricao'],
    quantidade: map['quantidade'],
    valorUnitario: map['valorUnitario'],
  );
}