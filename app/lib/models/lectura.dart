/// Modelo de datos para una lectura de contador
class Lectura {
  final int? id;
  final String contadorId;
  final String nombreUsuario;
  final String vereda;
  final double lectura;
  final String fotoPath;
  final double? latitud;
  final double? longitud;
  final DateTime fecha;
  final bool sincronizado;

  final String? comentario;

  const Lectura({
    this.id,
    required this.contadorId,
    required this.nombreUsuario,
    required this.vereda,
    required this.lectura,
    required this.fotoPath,
    this.latitud,
    this.longitud,
    required this.fecha,
    this.sincronizado = false,
    this.comentario,
  });

  /// Crea una Lectura desde un Map (base de datos)
  factory Lectura.fromMap(Map<String, dynamic> map) {
    return Lectura(
      id: map['id'] as int?,
      contadorId: map['contador_id'] as String,
      nombreUsuario: map['nombre_usuario'] as String,
      vereda: map['vereda'] as String,
      lectura: (map['lectura'] as num).toDouble(),
      fotoPath: map['foto_path'] as String,
      latitud: map['latitud'] as double?,
      longitud: map['longitud'] as double?,
      fecha: DateTime.parse(map['fecha'] as String),
      sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
      comentario: map['comentario'] as String?,
    );
  }

  /// Convierte a Map para guardar en base de datos
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'contador_id': contadorId,
      'nombre_usuario': nombreUsuario,
      'vereda': vereda,
      'lectura': lectura,
      'foto_path': fotoPath,
      'latitud': latitud,
      'longitud': longitud,
      'fecha': fecha.toIso8601String(),
      'sincronizado': sincronizado ? 1 : 0,
      'comentario': comentario,
    };
  }

  /// Indica si tiene coordenadas GPS válidas
  bool get tieneGps => latitud != null && longitud != null;

  /// Texto formateado de la lectura
  String get lecturaFormateada => '${lectura.toStringAsFixed(0)} m³';

  /// Texto formateado de la ubicación GPS
  String get ubicacionFormateada {
    if (!tieneGps) return 'Sin GPS';
    return '${latitud!.toStringAsFixed(4)}, ${longitud!.toStringAsFixed(4)}';
  }

  /// Texto formateado de la fecha
  String get fechaFormateada {
    final meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${fecha.day} ${meses[fecha.month]} ${fecha.year}, '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  /// Copia la lectura con nuevos valores
  Lectura copyWith({
    int? id,
    String? contadorId,
    String? nombreUsuario,
    String? vereda,
    double? lectura,
    String? fotoPath,
    double? latitud,
    double? longitud,
    DateTime? fecha,
    bool? sincronizado,
    String? comentario,
  }) {
    return Lectura(
      id: id ?? this.id,
      contadorId: contadorId ?? this.contadorId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      vereda: vereda ?? this.vereda,
      lectura: lectura ?? this.lectura,
      fotoPath: fotoPath ?? this.fotoPath,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fecha: fecha ?? this.fecha,
      sincronizado: sincronizado ?? this.sincronizado,
      comentario: comentario ?? this.comentario,
    );
  }

  /// Convierte a lista de strings para exportar CSV
  List<String> toCsvRow() {
    return [
      contadorId,
      nombreUsuario,
      vereda,
      lectura.toString(),
      fechaFormateada,
      latitud?.toString() ?? '',
      longitud?.toString() ?? '',
      fotoPath,
      comentario ?? '',
    ];
  }

  /// Headers para CSV
  static List<String> get csvHeaders => [
    'ID_Contador',
    'Nombre',
    'Vereda',
    'Lectura',
    'Fecha',
    'Latitud',
    'Longitud',
    'Foto',
    'Comentario',
  ];

  @override
  String toString() {
    return 'Lectura(id: $id, contador: $contadorId, lectura: $lectura)';
  }
}
