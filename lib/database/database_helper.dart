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
    // Tabela de Orçamentos com coluna 'itens' para o JSON
    await db.execute('''
    CREATE TABLE orcamentos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente TEXT NOT NULL,
      valor_total REAL NOT NULL,
      data TEXT NOT NULL,
      itens TEXT NOT NULL 
    )
  ''');

    // Tabela de Catálogo de Produtos
    await db.execute('''
    CREATE TABLE produtos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      preco_base REAL NOT NULL
    )
  ''');
  }

  Future<int> insert(Orcamento orcamento) async {
    final db = await instance.database;
    return await db.insert('orcamentos', orcamento.toMap());
  }
}