import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ConfiguracoesPage extends StatefulWidget {
  @override
  _ConfiguracoesPageState createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _respController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final dados = await DatabaseHelper.instance.getConfiguracao();
    setState(() {
      _nomeController.text = dados['nome_empresa'] ?? '';
      _cnpjController.text = dados['cnpj'] ?? '';
      _emailController.text = dados['email'] ?? '';
      _telController.text = dados['telefone'] ?? '';
      _respController.text = dados['responsavel'] ?? '';
    });
  }

  void _salvar() async {
    await DatabaseHelper.instance.updateConfiguracao({
      'nome_empresa': _nomeController.text,
      'cnpj': _cnpjController.text,
      'email': _emailController.text,
      'telefone': _telController.text,
      'responsavel': _respController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dados salvos!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar Empresa'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(controller: _nomeController, decoration: InputDecoration(labelText: 'Nome da Empresa')),
              TextField(controller: _cnpjController, decoration: InputDecoration(labelText: 'CNPJ')),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'E-mail')),
              TextField(controller: _telController, decoration: InputDecoration(labelText: 'Telefone')),
              TextField(controller: _respController, decoration: InputDecoration(labelText: 'Responsável')),
              SizedBox(height: 30),
              ElevatedButton(onPressed: _salvar, child: Text('Salvar Configurações'))
            ],
          ),
        ),
      ),
    );
  }
}