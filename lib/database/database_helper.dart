import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/orcamento.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // ==========================================
  // AMBIENTE WEB (Mock de Dados em Memória)
  // ==========================================
  final List<Orcamento> _mockWebDB = [];
  Map<String, dynamic> _mockConfig = {
    'nome_empresa': 'Sua Empresa de Software',
    'cnpj': '00.000.000/0001-00',
    'email': 'contato@empresa.com.br',
    'telefone': '(00) 90000-0000',
    'responsavel': 'Francisco Soares'
  };

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orcamentos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE orcamentos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente TEXT NOT NULL,
      valor_total REAL NOT NULL,
      data TEXT NOT NULL,
      itens TEXT NOT NULL 
    )
    ''');

    await db.execute('''
    CREATE TABLE configuracoes (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      nome_empresa TEXT,
      cnpj TEXT,
      email TEXT,
      telefone TEXT,
      responsavel TEXT
    )
    ''');

    await db.insert('configuracoes', {
      'id': 1,
      'nome_empresa': 'Sua Empresa de Software',
      'cnpj': '00.000.000/0001-00',
      'email': 'contato@empresa.com.br',
      'telefone': '(00) 90000-0000',
      'responsavel': 'Francisco Soares'
    });
  }

  // --- MÉTODOS DE ORÇAMENTO ---
  Future<int> insert(Orcamento orcamento) async {
    // Se for Web, salva na memória RAM temporária
    if (kIsWeb) {
      orcamento.id = _mockWebDB.length + 1;
      _mockWebDB.add(orcamento);
      return orcamento.id!;
    }

    // Se for Celular, salva no SQLite oficial
    final db = await instance.database;
    return await db.insert('orcamentos', orcamento.toMap());
  }

  Future<List<Orcamento>> getOrcamentos() async {
    if (kIsWeb) {
      return _mockWebDB.reversed.toList(); // Retorna do mais novo para o mais velho
    }

    final db = await instance.database;
    final result = await db.query('orcamentos', orderBy: 'data DESC');
    return result.map((json) => Orcamento.fromMap(json)).toList();
  }

  Future<int> deleteOrcamento(int id) async {
    if (kIsWeb) {
      _mockWebDB.removeWhere((orc) => orc.id == id);
      return 1;
    }

    final db = await instance.database;
    return await db.delete('orcamentos', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS DE CONFIGURAÇÃO ---
  Future<Map<String, dynamic>> getConfiguracao() async {
    if (kIsWeb) return _mockConfig;

    final db = await instance.database;
    final maps = await db.query('configuracoes', where: 'id = 1');
    return maps.first;
  }

  Future<int> updateConfiguracao(Map<String, dynamic> config) async {
    if (kIsWeb) {
      _mockConfig = config;
      return 1;
    }

    final db = await instance.database;
    return await db.update('configuracoes', config, where: 'id = 1');
  }
}