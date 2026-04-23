import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/orcamento.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orcamentos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabela de Orçamentos
    await db.execute('''
    CREATE TABLE orcamentos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente TEXT NOT NULL,
      valor_total REAL NOT NULL,
      data TEXT NOT NULL,
      itens TEXT NOT NULL 
    )
    ''');

    // Tabela de Configurações da Empresa (Engrenagem)
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

    // Insere uma configuração vazia inicial
    await db.insert('configuracoes', {
      'id': 1,
      'nome_empresa': 'Minha Empresa',
      'cnpj': '00.000.000/0001-00',
      'email': 'email@exemplo.com',
      'telefone': '(00) 00000-0000',
      'responsavel': 'Seu Nome'
    });
  }

  // --- MÉTODOS DE ORÇAMENTO ---
  Future<int> insert(Orcamento orcamento) async {
    final db = await instance.database;
    return await db.insert('orcamentos', orcamento.toMap());
  }

  Future<List<Orcamento>> getOrcamentos() async {
    final db = await instance.database;
    final result = await db.query('orcamentos', orderBy: 'data DESC');
    return result.map((json) => Orcamento.fromMap(json)).toList();
  }

  Future<int> deleteOrcamento(int id) async {
    final db = await instance.database;
    return await db.delete('orcamentos', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS DE CONFIGURAÇÃO ---
  Future<Map<String, dynamic>> getConfiguracao() async {
    final db = await instance.database;
    final maps = await db.query('configuracoes', where: 'id = 1');
    return maps.first;
  }

  Future<int> updateConfiguracao(Map<String, dynamic> config) async {
    final db = await instance.database;
    return await db.update('configuracoes', config, where: 'id = 1');
  }
}