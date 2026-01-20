import '../config/constants.dart';

/// Modelo de datos para un contador de agua
class Contador {
  final String id;
  final String nombre;
  final String vereda;
  final String? lote;

  final double? ultimaLectura;
  final DateTime? fechaUltimaLectura;
  final EstadoContador estado;

  const Contador({
    required this.id,
    required this.nombre,
    required this.vereda,
    this.lote,

    this.ultimaLectura,
    this.fechaUltimaLectura,
    this.estado = EstadoContador.pendiente,
  });

  /// Crea un Contador desde un Map (base de datos)
  factory Contador.fromMap(Map<String, dynamic> map) {
    return Contador(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      vereda: map['vereda'] as String,
      lote: map['lote'] as String?,

      ultimaLectura: map['ultima_lectura'] as double?,
      fechaUltimaLectura: map['fecha_ultima_lectura'] != null
          ? DateTime.parse(map['fecha_ultima_lectura'] as String)
          : null,
      estado: EstadoContador.values.firstWhere(
        (e) => e.name == (map['estado'] ?? 'pendiente'),
        orElse: () => EstadoContador.pendiente,
      ),
    );
  }

  /// Convierte a Map para guardar en base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'vereda': vereda,
      'lote': lote,

      'ultima_lectura': ultimaLectura,
      'fecha_ultima_lectura': fechaUltimaLectura?.toIso8601String(),
      'estado': estado.name,
    };
  }

  /// Texto formateado del sector y lote
  String get ubicacionCompleta {
    if (lote != null && lote!.isNotEmpty) {
      return '$vereda - $lote';
    }
    return vereda;
  }

  /// Texto formateado de la última lectura
  String get ultimaLecturaFormateada {
    if (ultimaLectura == null) return 'Sin lectura';
    return '${ultimaLectura!.toStringAsFixed(0)} m³';
  }

  /// Copia el contador con nuevos valores
  Contador copyWith({
    String? id,
    String? nombre,
    String? vereda,
    String? lote,

    double? ultimaLectura,
    DateTime? fechaUltimaLectura,
    EstadoContador? estado,
  }) {
    return Contador(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      vereda: vereda ?? this.vereda,
      lote: lote ?? this.lote,

      ultimaLectura: ultimaLectura ?? this.ultimaLectura,
      fechaUltimaLectura: fechaUltimaLectura ?? this.fechaUltimaLectura,
      estado: estado ?? this.estado,
    );
  }

  @override
  String toString() {
    return 'Contador(id: $id, nombre: $nombre, vereda: $vereda)';
  }
}
