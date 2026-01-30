import 'package:latlong2/latlong.dart';
import '../models/contador.dart';
import 'database_service.dart';

class MapService {
  final DatabaseService _databaseService = DatabaseService();

  // Singleton pattern for easy state persistence across the app
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // Persistent camera state
  LatLng? lastCenter;
  double? lastZoom;
  double? lastRotation;

  /// Obtiene los contadores que tienen coordenadas GPS válidas
  Future<List<Contador>> getContadoresConUbicacion() async {
    final allContadores = await _databaseService.getContadores();

    // Filtrar solo los que tienen latitud y longitud
    return allContadores
        .where((c) => c.latitud != null && c.longitud != null)
        .toList();
  }
}
