import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../services/database_service.dart';
import '../services/map_service.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'registro_lectura_screen.dart';
import '../widgets/info_lectura_widget.dart'; // Ensure this widget exists or is created

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  final DatabaseService _databaseService =
      DatabaseService(); // Keep for specific actions like getLecturaActiva
  List<Contador> _contadores = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();

  // Custom visual assets
  // You might want to use custom icons here, but we'll build them with Flutter widgets first

  @override
  void initState() {
    super.initState();
    _loadContadores();
  }

  Future<void> _loadContadores() async {
    setState(() => _isLoading = true);
    // Use MapService to get counters
    final contadoresWithLocation = await _mapService
        .getContadoresConUbicacion();

    setState(() {
      _contadores = contadoresWithLocation;
      _isLoading = false;
    });

    if (_contadores.isNotEmpty) {
      // Center map on the first point or average
      Future.delayed(const Duration(milliseconds: 500), () {
        _mapController.move(
          LatLng(_contadores.first.latitud!, _contadores.first.longitud!),
          15,
        );
      });
    }
  }

  void _showContadorDetails(Contador contador) async {
    // Check current reading status
    final lecturaActiva = await _databaseService.getLecturaActiva(contador.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          contador.estado == EstadoContador.registrado
                              ? Icons.check_circle
                              : Icons.pending,
                          color: contador.estado == EstadoContador.registrado
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contador.nombre,
                                style: AppTextStyles.subtitulo,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${contador.vereda} • ${contador.id}',
                                style: AppTextStyles.cuerpoSecundario,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        if (lecturaActiva != null) ...[
                          Text(
                            'Lectura Registrada',
                            style: AppTextStyles.titulo.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          InfoLecturaWidget(lectura: lecturaActiva),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('VER / EDITAR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Close sheet
                                // Open dialog logic or navigate
                                _abrirDialogoEdicion(contador, lecturaActiva);
                              },
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Lectura Pendiente',
                            style: AppTextStyles.titulo.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Última lectura: ${contador.ultimaLecturaFormateada}',
                            style: AppTextStyles.cuerpoSecundario,
                          ),
                          const SizedBox(height: 24),
                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text('REGISTRAR LECTURA'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, // Primary action
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegistroLecturaScreen(
                                      contador: contador,
                                      veredaOrigen: contador.vereda,
                                    ),
                                  ),
                                );
                                _loadContadores(); // Refresh map
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _abrirDialogoEdicion(Contador contador, Lectura lectura) {
    // Reusing the logic from the user request, simplified since valid checks are done
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Lectura Registrada',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoLecturaWidget(lectura: lectura),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('EDITAR REGISTRO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistroLecturaScreen(
                            contador: contador,
                            lecturaExistente: lectura,
                            veredaOrigen: contador.vereda,
                          ),
                        ),
                      );
                      _loadContadores();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Contadores')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(4.6097, -74.0817), // Default if no data
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.asoguapo.app',
                ),
                MarkerLayer(
                  markers: _contadores.map((contador) {
                    final isDone = contador.estado == EstadoContador.registrado;
                    return Marker(
                      point: LatLng(contador.latitud!, contador.longitud!),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _showContadorDetails(contador),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? Colors.green : Colors.grey[200],
                            border: Border.all(
                              color: isDone ? Colors.white : Colors.red,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(blurRadius: 4, color: Colors.black26),
                            ],
                          ),
                          child: Icon(
                            Icons.water_drop,
                            color: isDone ? Colors.white : Colors.grey[600],
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
