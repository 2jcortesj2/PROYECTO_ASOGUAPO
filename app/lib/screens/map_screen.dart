import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'dart:async';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../services/database_service.dart';
import '../services/map_service.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'registro_lectura_screen.dart';
import '../widgets/info_lectura_widget.dart';

/// Custom Marker to hold Contador data for O(1) access in clusters
class ContadorMarker extends Marker {
  final Contador contador;
  final bool isDone;

  const ContadorMarker({
    required super.point,
    required super.child,
    required super.width,
    required super.height,
    super.rotate,
    required this.contador,
    required this.isDone,
  });
}

/// Helper for listening to two ValueListenables
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, _) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}

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

  String _searchQuery = '';
  String _veredaSeleccionada = 'El Tendido';
  bool _ocultarCompletados = false;
  bool _isFirstLoad = true;

  // Granular state for heavy map updates
  final ValueNotifier<double> _zoomNotifier = ValueNotifier(15.0);
  final ValueNotifier<double> _rotationNotifier = ValueNotifier(270.0);

  // Memoized markers
  List<ContadorMarker> _memoizedMarkers = [];

  final List<String> _veredas = [
    'El Recreo',
    'Pueblo Nuevo',
    'El Tendido',
    'Todas',
  ];

  // Interaction state
  bool _isInteracting = false;
  Timer? _inactivityTimer;
  Contador? _selectedContador;

  @override
  void initState() {
    super.initState();
    if (widget.initialVereda != null) {
      _veredaSeleccionada = widget.initialVereda!;
    }
    _zoomNotifier.value = _mapService.lastZoom ?? 15.0;
    _rotationNotifier.value = _mapService.lastRotation ?? 270.0;
    _loadContadores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _zoomNotifier.dispose();
    _rotationNotifier.dispose();
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
      _generarMarcadores(); // Build markers once
      // After first load, we can set _isFirstLoad to false after a short delay for the animation
      if (_isFirstLoad) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _isFirstLoad = false);
        });
      }
    });

    if (_contadores.isNotEmpty) {
      // Re-center on first load if needed
      _actualizarMapa();
    }
  }

  List<Contador> get _contadoresFiltrados {
    return _contadores.where((c) {
      if (_veredaSeleccionada != 'Todas' &&
          c.vereda.toUpperCase() != _veredaSeleccionada.toUpperCase()) {
        return false;
      }
      if (_ocultarCompletados && c.estado == EstadoContador.registrado) {
        return false;
      }

      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      return c.nombre.toLowerCase().contains(query) ||
          c.id.toLowerCase().contains(query);
    }).toList();
  }

  void _actualizarMapa() {
    if (_contadores.isEmpty) return;

    // Si ya tenemos una posición guardada de esta sesión, no forzamos el re-encuadre
    if (_mapService.lastCenter != null) return;

    if (_veredaSeleccionada != 'El Tendido' && _veredaSeleccionada != 'Todas') {
      return;
    }

    final points = _contadoresFiltrados
        .map((c) => LatLng(c.latitud!, c.longitud!))
        .toList();

    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    });
  }

  void _generarMarcadores() {
    final filtrados = _contadoresFiltrados;

    _memoizedMarkers = filtrados.map((contador) {
      final isDone = contador.estado == EstadoContador.registrado;

      return ContadorMarker(
        point: LatLng(contador.latitud!, contador.longitud!),
        width: 250, // Large enough to prevent clipping at high zoom
        height: 250,
        rotate: false,
        contador: contador,
        isDone: isDone,
        child: _buildMarkerWidget(contador, isDone),
      );
    }).toList();
  }

  double _getMarkerSize(double zoom) {
    return (30.0 * (zoom / 15.0) * (zoom / 15.0)).clamp(10.0, 250.0);
  }

  Widget _buildMarkerWidget(Contador contador, bool isDone) {
    return ValueListenableBuilder2<double, double>(
      first: _zoomNotifier,
      second: _rotationNotifier,
      builder: (context, zoom, rotation, child) {
        final double size = _getMarkerSize(zoom);
        final bool isSelected = contador == _selectedContador;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedContador = contador;
            });
          },
          child: Transform.rotate(
            angle: -rotation * math.pi / 180,
            child: Stack(
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Sombra (Shadow)
                      Transform.translate(
                        offset: Offset(size * 0.05, size * 0.05),
                        child: Icon(
                          Icons.water_drop,
                          color: Colors.black.withValues(alpha: 0.35),
                          size: size,
                        ),
                      ),
                      // Selection Ring (Highlight)
                      if (isSelected)
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3.0,
                            ),
                          ),
                        ),
                      // Icono Principal
                      isDone
                          ? ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersistentInfoBox() {
    if (_selectedContador == null) return const SizedBox.shrink();

    final contador = _selectedContador!;
    final isDone = contador.estado == EstadoContador.registrado;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => _handleInfoBoxTap(contador),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Pending Status Icon updated to gray circle
              Icon(
                isDone
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked, // Updated icon
                color: isDone ? Colors.green : Colors.grey, // Updated color
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contador.nombre,
                      style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${contador.vereda} • ${contador.id}',
                      style: AppTextStyles.cuerpoSecundario,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() => _selectedContador = null);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleInfoBoxTap(Contador contador) async {
    final lecturaActiva = await _databaseService.getLecturaActiva(contador.id);
    if (!mounted) return;

    if (lecturaActiva != null) {
      _abrirDialogoEdicion(contador, lecturaActiva);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistroLecturaScreen(
            contador: contador,
            veredaOrigen: contador.vereda,
          ),
        ),
      );
      _loadContadores();
    }
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
          _generarMarcadores(); // Re-generate markers when filter changes
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
        elevation: 0,
        backgroundColor: _isInteracting
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        // Animate color transition
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Column(
          children: [
            Text(
              'Lectura en Mapa',
              style: AppTextStyles.titulo.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
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
            color: AppColors.textPrimary,
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _generarMarcadores();
                });
              },
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
                  '${_memoizedMarkers.length} contadores',
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
                      onChanged: (value) {
                        setState(() {
                          _ocultarCompletados = value;
                          _generarMarcadores();
                        });
                      },
                      activeTrackColor: AppColors.primary.withValues(
                        alpha: 0.5,
                      ),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                _veredaSeleccionada != 'El Tendido'
                    ? _buildEnConstruccion()
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _mapService.lastCenter ??
                              const LatLng(2.389, -75.525),
                          initialZoom: _mapService.lastZoom ?? 15,
                          initialRotation:
                              _mapService.lastRotation ??
                              270, // West to East orientation (bearing)
                          minZoom: 12,
                          maxZoom: 21,
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              if (!_isInteracting) {
                                setState(() => _isInteracting = true);
                              }
                              _inactivityTimer?.cancel();
                              _inactivityTimer = Timer(
                                const Duration(seconds: 5),
                                () {
                                  if (mounted) {
                                    setState(() => _isInteracting = false);
                                  }
                                },
                              );
                            }
                            final camera = _mapController.camera;
                            _zoomNotifier.value = camera.zoom;
                            _rotationNotifier.value = camera.rotation;
                            // Persist the state in the service
                            _mapService.lastZoom = camera.zoom;
                            _mapService.lastCenter = camera.center;
                            _mapService.lastRotation = camera.rotation;
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
                          ),
                          ValueListenableBuilder<double>(
                            valueListenable: _zoomNotifier,
                            builder: (context, zoom, _) {
                              // Dynamic radius: aggressive exponential decay
                              final dynamicRadius =
                                  (150.0 * math.pow(0.76, zoom - 12)).clamp(
                                    5.0,
                                    100.0,
                                  );

                              // Calculate base drop size for the cluster (1.6x individual marker)
                              final clusterSize = _getMarkerSize(zoom) * 1.6;

                              return MarkerClusterLayerWidget(
                                options: MarkerClusterLayerOptions(
                                  maxClusterRadius: dynamicRadius.toInt(),
                                  size: Size(
                                    clusterSize,
                                    clusterSize,
                                  ), // Dynamic size synchronizes with content
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(50),
                                  markers: _memoizedMarkers,
                                  builder: (context, markers) {
                                    final contadorMarkers = markers
                                        .whereType<ContadorMarker>();
                                    final bool allDone =
                                        contadorMarkers.isNotEmpty &&
                                        contadorMarkers.every((m) => m.isDone);
                                    final bool anyDone = contadorMarkers.any(
                                      (m) => m.isDone,
                                    );

                                    return ValueListenableBuilder2<
                                      double,
                                      double
                                    >(
                                      first: _zoomNotifier,
                                      second: _rotationNotifier,
                                      builder: (context, z, rotation, _) {
                                        final iconSize = clusterSize * 0.8;
                                        final badgeSize = clusterSize * 0.35;
                                        final badgeFontSize =
                                            (clusterSize * 0.15).clamp(
                                              8.0,
                                              32.0,
                                            );
                                        final badgePadding = clusterSize * 0.04;

                                        return Transform.rotate(
                                          angle: -rotation * math.pi / 180,
                                          child: Center(
                                            child: SizedBox(
                                              width: iconSize,
                                              height: iconSize,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  // Shadow
                                                  Positioned.fill(
                                                    child: Transform.translate(
                                                      offset: Offset(
                                                        iconSize * 0.05,
                                                        iconSize * 0.05,
                                                      ),
                                                      child: Icon(
                                                        Icons.water_drop,
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        size: iconSize,
                                                      ),
                                                    ),
                                                  ),
                                                  // Main Icon
                                                  Icon(
                                                    Icons.water_drop,
                                                    color: allDone
                                                        ? AppColors.primary
                                                        : Colors.grey[400],
                                                    size: iconSize,
                                                  ),
                                                  // Badge
                                                  Positioned(
                                                    right: -badgeSize * 0.2,
                                                    top: -badgeSize * 0.2,
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        badgePadding,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient: anyDone
                                                            ? const LinearGradient(
                                                                colors: [
                                                                  AppColors
                                                                      .primary,
                                                                  AppColors
                                                                      .secondary,
                                                                ],
                                                              )
                                                            : null,
                                                        color: anyDone
                                                            ? null
                                                            : Colors.grey[600],
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                (anyDone
                                                                        ? AppColors
                                                                              .primary
                                                                        : Colors
                                                                              .black)
                                                                    .withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                            blurRadius:
                                                                clusterSize *
                                                                0.1,
                                                            spreadRadius:
                                                                clusterSize *
                                                                0.03,
                                                          ),
                                                        ],
                                                      ),
                                                      constraints:
                                                          BoxConstraints(
                                                            minWidth: badgeSize,
                                                            minHeight:
                                                                badgeSize,
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          markers.length
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                badgeFontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          _buildPersistentInfoBox(),
                        ],
                      ),
                if (_isFirstLoad || _isLoading) _buildLoadingScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return AnimatedOpacity(
      opacity: _isFirstLoad || _isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo_asoguapo.png', width: 120, height: 120),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando mapa...',
                style: AppTextStyles.cuerpo.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
