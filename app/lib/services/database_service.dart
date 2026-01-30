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
      version: 5, // Incrementado para incluir coordenadas en contadores
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Agregar columna comentario si viene de versión 2
      await db.execute('ALTER TABLE lecturas ADD COLUMN comentario TEXT');
    }

    if (oldVersion < 4) {
      // Permitir NULL en columna lectura
      // SQLite no soporta ALTER COLUMN, así que recreamos la tabla
      await db.execute('''
        CREATE TABLE lecturas_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contador_id TEXT NOT NULL,
          nombre_usuario TEXT NOT NULL,
          vereda TEXT NOT NULL,
          lectura REAL,
          foto_path TEXT NOT NULL,
          latitud REAL,
          longitud REAL,
          fecha TEXT NOT NULL,
          sincronizado INTEGER DEFAULT 0,
          comentario TEXT,
          FOREIGN KEY (contador_id) REFERENCES contadores(id)
        )
      ''');

      // Copiar datos
      await db.execute('''
        INSERT INTO lecturas_new 
        SELECT * FROM lecturas
      ''');

      // Eliminar tabla vieja y renombrar
      await db.execute('DROP TABLE lecturas');
      await db.execute('ALTER TABLE lecturas_new RENAME TO lecturas');

      // Recrear índices
      await db.execute('CREATE INDEX idx_lecturas_fecha ON lecturas(fecha)');
      await db.execute(
        'CREATE INDEX idx_lecturas_contador ON lecturas(contador_id)',
      );
    }

    if (oldVersion < 5) {
      // Agregar latitud y longitud a contadores
      await db.execute('ALTER TABLE contadores ADD COLUMN latitud REAL');
      await db.execute('ALTER TABLE contadores ADD COLUMN longitud REAL');
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
        estado TEXT,
        latitud REAL,
        longitud REAL
      )
    ''');

    // Tabla de Lecturas
    await db.execute('''
      CREATE TABLE lecturas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contador_id TEXT NOT NULL,
        nombre_usuario TEXT NOT NULL,
        vereda TEXT NOT NULL,
        lectura REAL,
        foto_path TEXT NOT NULL,
        latitud REAL,
        longitud REAL,
        fecha TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0,
        comentario TEXT,
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

  // Actualizar solo coordenadas (para preservar estado y lecturas al importar CSV nuevo)
  Future<void> updateContadorUbicacion(
    String id,
    double lat,
    double lng,
  ) async {
    final db = await database;
    await db.update(
      'contadores',
      {'latitud': lat, 'longitud': lng},
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

  Future<Lectura?> getLecturaActiva(String contadorId) async {
    final db = await database;

    // 1. Obtener la primera lectura tomada en el sistema (la más antigua que aún está activa)
    // Para simplificar, buscamos la lectura más antigua entre las que tienen estado 'registrado' en su contador
    final List<Map<String, dynamic>> firstReadingQuery = await db.rawQuery('''
      SELECT MIN(fecha) as primera_fecha FROM lecturas l
      JOIN contadores c ON l.contador_id = c.id
      WHERE c.estado = 'registrado'
    ''');

    if (firstReadingQuery.first['primera_fecha'] == null) return null;

    final DateTime primeraFecha = DateTime.parse(
      firstReadingQuery.first['primera_fecha'] as String,
    );
    final now = DateTime.now();
    final diferenciaGlobal = now.difference(primeraFecha).inDays;

    // Si el ciclo global (desde la primera toma) superó los 15 días, nada es editable
    if (diferenciaGlobal >= 15) return null;

    // 2. Si estamos dentro del ciclo, buscar la lectura específica de este contador
    final List<Map<String, dynamic>> maps = await db.query(
      'lecturas',
      where: 'contador_id = ?',
      whereArgs: [contadorId],
      orderBy: 'fecha DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Lectura.fromMap(maps.first);
  }

  /// Limpia fotos antiguas y realiza el rollover mensual global (>15 días desde la primera toma)
  Future<void> limpiarYActualizarRegistros() async {
    final db = await database;

    // 1. Encontrar la fecha de la primera lectura del ciclo actual
    final List<Map<String, dynamic>> firstReadingQuery = await db.rawQuery('''
      SELECT MIN(fecha) as primera_fecha FROM lecturas l
      JOIN contadores c ON l.contador_id = c.id
      WHERE c.estado = 'registrado'
    ''');

    if (firstReadingQuery.first['primera_fecha'] == null) return;

    final DateTime primeraFecha = DateTime.parse(
      firstReadingQuery.first['primera_fecha'] as String,
    );
    final now = DateTime.now();
    final diasDesdeInicio = now.difference(primeraFecha).inDays;

    // SOLO si han pasado 15 días o más desde la PRIMERA toma del mes, hacemos el rollover
    if (diasDesdeInicio < 15) return;

    // 2. Obtener todas las lecturas del ciclo que terminó
    final List<Map<String, dynamic>> oldLecturas = await db.rawQuery('''
      SELECT l.* FROM lecturas l
      JOIN contadores c ON l.contador_id = c.id
      WHERE c.estado = 'registrado'
    ''');

    for (var row in oldLecturas) {
      final lectura = Lectura.fromMap(row);

      // A. Borrar archivo físico de foto para liberar espacio
      if (lectura.fotoPath.isNotEmpty) {
        final file = File(lectura.fotoPath);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
      }

      // B. Actualizar registro de lectura (quitar path de foto para integridad)
      await db.update(
        'lecturas',
        {'foto_path': ''},
        where: 'id = ?',
        whereArgs: [lectura.id],
      );

      // C. ROLLOVER: La lectura actual pasa a ser la del 'mes pasado' (ultima_lectura)
      // y el contador queda libre ('pendiente') para el nuevo mes
      // Si la lectura es nula (anomalía), guardamos null para preservar esa información
      await db.update(
        'contadores',
        {
          'ultima_lectura': lectura.lectura, // Puede ser null
          'fecha_ultima_lectura': lectura.fecha.toIso8601String(),
          'estado': EstadoContador.pendiente.name,
        },
        where: 'id = ?',
        whereArgs: [lectura.contadorId],
      );
    }
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
