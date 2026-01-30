import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../services/database_service.dart';
import '../services/map_service.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'registro_lectura_screen.dart';
import '../widgets/info_lectura_widget.dart'; // Ensure this widget exists or is created

class MapScreen extends StatefulWidget {
  final String? initialVereda;
  const MapScreen({super.key, this.initialVereda});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Contador> _contadores = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
  double _currentZoom = 15.0;
  CacheStore? _cacheStore;

  String _searchQuery = '';
  String _veredaSeleccionada = 'El Tendido';
  bool _ocultarCompletados = false;

  final List<String> _veredas = [
    'El Recreo',
    'Pueblo Nuevo',
    'El Tendido',
    'Todas',
  ];

  @override
  void initState() {
    super.initState();
    _initCache();
    if (widget.initialVereda != null) {
      _veredaSeleccionada = widget.initialVereda!;
    }
    _loadContadores();
  }

  Future<void> _initCache() async {
    setState(() {
      _cacheStore = MemCacheStore();
    });
  }

  @override
  void dispose() {
    _cacheStore?.close();
    _searchController.dispose();
    super.dispose();
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
      _actualizarMapa();
    }
  }

  void _actualizarMapa() {
    if (_contadores.isEmpty) return;
    if (_veredaSeleccionada != 'El Tendido' && _veredaSeleccionada != 'Todas')
      return;

    final points = _contadoresFiltrados
        .map((c) => LatLng(c.latitud!, c.longitud!))
        .toList();

    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);

    Future.delayed(const Duration(milliseconds: 500), () {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 400, vertical: 300),
        ),
      );
    });
  }

  List<Contador> get _contadoresFiltrados {
    final filtrados = _contadores.where((c) {
      if (_veredaSeleccionada != 'Todas' &&
          c.vereda.toUpperCase() != _veredaSeleccionada.toUpperCase()) {
        return false;
      }
      if (_ocultarCompletados && c.estado == EstadoContador.registrado)
        return false;

      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      return c.nombre.toLowerCase().contains(query) ||
          c.id.toLowerCase().contains(query);
    }).toList();

    return filtrados;
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

  LatLngBounds _calculateExpandedBounds(List<Contador> contadores) {
    if (contadores.isEmpty) {
      return LatLngBounds(
        const LatLng(2.30, -75.60),
        const LatLng(2.45, -75.40),
      );
    }

    double minLat = contadores.first.latitud!;
    double maxLat = contadores.first.latitud!;
    double minLng = contadores.first.longitud!;
    double maxLng = contadores.first.longitud!;

    for (final c in contadores) {
      if (c.latitud! < minLat) minLat = c.latitud!;
      if (c.latitud! > maxLat) maxLat = c.latitud!;
      if (c.longitud! < minLng) minLng = c.longitud!;
      if (c.longitud! > maxLng) maxLng = c.longitud!;
    }

    // Add much larger margin (50%) to the bounding box for easier navigation
    final double latDelta = (maxLat - minLat).abs();
    final double lngDelta = (maxLng - minLng).abs();

    // Ensure a generous margin
    final double latMargin = (latDelta * 0.5).clamp(0.01, 1.0);
    final double lngMargin = (lngDelta * 0.5).clamp(0.01, 1.0);

    return LatLngBounds(
      LatLng(minLat - latMargin, minLng - lngMargin),
      LatLng(maxLat + latMargin, maxLng + lngMargin),
    );
  }

  Widget _buildVeredaChip(String vereda) {
    final selected = _veredaSeleccionada == vereda;
    return GestureDetector(
      onTap: () {
        setState(() {
          _veredaSeleccionada = vereda;
        });
        if (vereda == 'El Tendido') {
          _actualizarMapa();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          vereda,
          style: AppTextStyles.cuerpo.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
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
    final fechaHoy = '${now.day} ${meses[now.month]} ${now.year}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text('Lecturas del Día', style: AppTextStyles.titulo),
            Text(
              fechaHoy,
              style: AppTextStyles.cuerpoSecundario.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.pop(context, _veredaSeleccionada),
            tooltip: 'Ver Lista',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar medidores...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          const SizedBox(height: 16),

          // Selector de Vereda
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: _veredas.map((v) => _buildVeredaChip(v)).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Contador y Toggle
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_contadoresFiltrados.length} contadores',
                  style: AppTextStyles.cuerpoSecundario,
                ),
                Row(
                  children: [
                    Text(
                      'Ocultar completados',
                      style: AppTextStyles.cuerpoSecundario.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _ocultarCompletados,
                      onChanged: (value) =>
                          setState(() => _ocultarCompletados = value),
                      activeTrackColor: AppColors.primary.withOpacity(0.5),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _veredaSeleccionada != 'El Tendido'
                ? _buildEnConstruccion()
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(2.389, -75.525),
                      initialZoom: 15,
                      initialRotation:
                          270, // West to East orientation (bearing)
                      minZoom: 12,
                      maxZoom: 21,
                      onPositionChanged: (position, hasGesture) {
                        setState(() {
                          _currentZoom = position.zoom ?? 16.0;
                        });
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      cameraConstraint: CameraConstraint.contain(
                        bounds: _calculateExpandedBounds(_contadores),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.asoguapo.app',
                        tileProvider: _cacheStore != null
                            ? CachedTileProvider(store: _cacheStore!)
                            : null,
                      ),
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 45,
                          size: const Size(45, 45),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(50),
                          markers: _contadoresFiltrados.map((contador) {
                            final isDone =
                                contador.estado == EstadoContador.registrado;
                            final double size =
                                (40 * (_currentZoom / 15) * (_currentZoom / 15))
                                    .clamp(10.0, 250.0);

                            return Marker(
                              point: LatLng(
                                contador.latitud!,
                                contador.longitud!,
                              ),
                              width: size,
                              height: size,
                              rotate:
                                  false, // Keep vertical icons upright relative to the screen
                              child: GestureDetector(
                                onTap: () => _showContadorDetails(contador),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: size * 0.05,
                                      top: size * 0.05,
                                      child: Icon(
                                        Icons.water_drop,
                                        color: Colors.black.withValues(
                                          alpha: 0.35,
                                        ),
                                        size: size,
                                      ),
                                    ),
                                    Center(
                                      child: isDone
                                          ? ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  const LinearGradient(
                                                    colors: [
                                                      AppColors.primary,
                                                      AppColors.secondary,
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ).createShader(bounds),
                                              child: Icon(
                                                Icons.water_drop,
                                                color: Colors.white,
                                                size: size,
                                              ),
                                            )
                                          : Icon(
                                              Icons.water_drop,
                                              color: Colors.grey[400],
                                              size: size,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          builder: (context, markers) {
                            // Check if any marker in the cluster is completed
                            // This requires accessing the custom data of the markers
                            // markers is a List<Marker>
                            // Since we can't easily store the Contador in the Marker object directly without a wrapper
                            // we'll assume the markers provided here are the ones we created in the markers: ... map()
                            // However, Marker doesn't have a 'key' or 'data' field by default.
                            // To solve this correctly, we should look at how we generate markers.
                            // For now, let's create a logic that checks if the cluster should be 'done'
                            // based on the presence of any marker that would have been green.
                            // ACTUALLY, we can filter our _contadores list where it matches the marker points.
                            // But that's slow. A better way is to pass the state in the Marker Key or use a custom Marker class.
                            // For simplicity, I will use a heuristic or check the _contadores list.

                            final clusterPoints = markers
                                .map((m) => m.point)
                                .toSet();
                            final clusterContadores = _contadoresFiltrados
                                .where(
                                  (c) => clusterPoints.contains(
                                    LatLng(c.latitud!, c.longitud!),
                                  ),
                                )
                                .toList();

                            final bool allDone =
                                clusterContadores.length > 0 &&
                                clusterContadores.every(
                                  (c) => c.estado == EstadoContador.registrado,
                                );
                            final bool anyDone = clusterContadores.any(
                              (c) => c.estado == EstadoContador.registrado,
                            );
                            const double clusterSize = 50.0;

                            return SizedBox(
                              width: clusterSize,
                              height: clusterSize,
                              child: Stack(
                                children: [
                                  // The main Water Drop icon
                                  // Colors completely ONLY if all are done.
                                  Center(
                                    child: Icon(
                                      Icons.water_drop,
                                      color: allDone
                                          ? AppColors.primary
                                          : Colors.grey[400],
                                      size: clusterSize * 0.8,
                                    ),
                                  ),
                                  // The Notification Globito (the badge)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: anyDone
                                            ? const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.secondary,
                                                ],
                                              )
                                            : null,
                                        color: anyDone
                                            ? null
                                            : Colors.grey[500],
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (anyDone
                                                        ? AppColors.primary
                                                        : Colors.black)
                                                    .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Center(
                                        child: Text(
                                          markers.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnConstruccion() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'En Construcción',
            style: AppTextStyles.titulo.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'El mapa para esta vereda estará disponible pronto.',
            textAlign: TextAlign.center,
            style: AppTextStyles.cuerpoSecundario,
          ),
        ],
      ),
    );
  }
}
