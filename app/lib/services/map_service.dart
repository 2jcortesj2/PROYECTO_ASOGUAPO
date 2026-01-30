import '../models/contador.dart';
import 'database_service.dart';

class MapService {
  final DatabaseService _databaseService = DatabaseService();

  /// Obtiene los contadores que tienen coordenadas GPS válidas
  Future<List<Contador>> getContadoresConUbicacion() async {
    final allContadores = await _databaseService.getContadores();

    // Filtrar solo los que tienen latitud y longitud
    return allContadores
        .where((c) => c.latitud != null && c.longitud != null)
        .toList();
  }
}
