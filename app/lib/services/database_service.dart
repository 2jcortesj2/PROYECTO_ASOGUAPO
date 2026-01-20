import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../config/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConstants.dbName);

    // Increment version if schema changes
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Recrear tablas si cambia versión (o hacer alter table si se prefiere conservar datos)
      // Como estamos en piloto y se reimporta todo, vamos a redrop
      await db.execute('DROP TABLE IF EXISTS lecturas');
      await db.execute('DROP TABLE IF EXISTS contadores');
      await _createDB(db, newVersion);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de Contadores
    await db.execute('''
      CREATE TABLE contadores (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        vereda TEXT NOT NULL,
        lote TEXT,
        ultima_lectura REAL,
        fecha_ultima_lectura TEXT,
        estado TEXT
      )
    ''');

    // Tabla de Lecturas
    await db.execute('''
      CREATE TABLE lecturas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contador_id TEXT NOT NULL,
        nombre_usuario TEXT NOT NULL,
        vereda TEXT NOT NULL,
        lectura REAL NOT NULL,
        foto_path TEXT NOT NULL,
        latitud REAL,
        longitud REAL,
        fecha TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0,
        FOREIGN KEY (contador_id) REFERENCES contadores(id)
      )
    ''');

    // Indices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_lecturas_fecha ON lecturas(fecha)');
    await db.execute(
      'CREATE INDEX idx_lecturas_contador ON lecturas(contador_id)',
    );
  }

  // --- CONTADORES ---

  Future<int> insertContador(Contador contador) async {
    final db = await database;
    return await db.insert(
      'contadores',
      contador.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contador>> getContadores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contadores');
    return List.generate(maps.length, (i) {
      return Contador.fromMap(maps[i]);
    });
  }

  Future<Contador?> getContadorById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contadores',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contador.fromMap(maps.first);
    }
    return null;
  }

  // Actualizar el estado de un contador
  Future<void> updateEstadoContador(String id, EstadoContador estado) async {
    final db = await database;
    await db.update(
      'contadores',
      {'estado': estado.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- LECTURAS ---

  Future<int> insertLectura(Lectura lectura) async {
    final db = await database;
    int id = await db.insert('lecturas', lectura.toMap());

    // Actualizar estado del contador a 'registrado'
    await updateEstadoContador(lectura.contadorId, EstadoContador.registrado);

    return id;
  }

  Future<List<Lectura>> getLecturas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lecturas',
      orderBy: 'fecha DESC',
    );
    return List.generate(maps.length, (i) {
      return Lectura.fromMap(maps[i]);
    });
  }

  Future<Lectura?> getLecturaPorContadorHoy(String contadorId) async {
    final db = await database;
    // Obtener lecturas del contador ordenadas por fecha reciente
    final List<Map<String, dynamic>> maps = await db.query(
      'lecturas',
      where: 'contador_id = ?',
      whereArgs: [contadorId],
      orderBy: 'fecha DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final lectura = Lectura.fromMap(maps.first);
    final now = DateTime.now();

    // Verificar estrictamente si la lectura es de HOY
    final isSameDay =
        lectura.fecha.year == now.year &&
        lectura.fecha.month == now.month &&
        lectura.fecha.day == now.day;

    if (isSameDay) {
      return lectura;
    }

    return null;
  }

  Future<void> updateLectura(Lectura lectura) async {
    final db = await database;
    await db.update(
      'lecturas',
      lectura.toMap(),
      where: 'id = ?',
      whereArgs: [lectura.id],
    );
  }

  Future<void> deleteAllContadores() async {
    final db = await database;
    await db.delete('contadores');
  }

  Future<void> deleteAllLecturas() async {
    final db = await database;
    await db.delete('lecturas');
  }

  Future<void> resetEstadoContadores() async {
    final db = await database;
    await db.update('contadores', {'estado': EstadoContador.pendiente.name});
  }

  Future<void> deleteLectura(int id) async {
    final db = await database;

    // Obtener la lectura para saber qué contador resetear
    final List<Map<String, dynamic>> maps = await db.query(
      'lecturas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final lectura = Lectura.fromMap(maps.first);

      // Borrar la lectura
      await db.delete('lecturas', where: 'id = ?', whereArgs: [id]);

      // Resetear estado del contador a pendiente
      await updateEstadoContador(lectura.contadorId, EstadoContador.pendiente);

      // Borrar archivo de foto si existe
      if (lectura.fotoPath.isNotEmpty) {
        final file = File(lectura.fotoPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }
}
