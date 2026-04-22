class Orcamento {
  int? id;
  String cliente;
  double valor;
  String data;

  Orcamento({
    this.id,
    required this.cliente,
    required this.valor,
    required this.data,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'valor': valor,
      'data': data,
    };
  }


  factory Orcamento.fromMap(Map<String, dynamic> map) {
    return Orcamento(
      id: map['id'],
      cliente: map['cliente'],
      valor: map['valor'],
      data: map['data'],
    );
  }
}