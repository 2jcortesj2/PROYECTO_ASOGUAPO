import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../widgets/contador_card.dart';
import '../widgets/info_lectura_widget.dart';
import '../services/database_service.dart';
import 'registro_lectura_screen.dart';
import 'historial_screen.dart';
import 'map_screen.dart';

/// Pantalla principal - Lista de contadores
class ListaContadoresScreen extends StatefulWidget {
  final String? veredaInicial;

  const ListaContadoresScreen({super.key, this.veredaInicial});

  @override
  State<ListaContadoresScreen> createState() => _ListaContadoresScreenState();
}

class _ListaContadoresScreenState extends State<ListaContadoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _veredaSeleccionada = 'El Recreo';
  final List<String> _veredas = [
    'El Recreo',
    'Pueblo Nuevo',
    'El Tendido',
    'Todas',
  ];
  final DatabaseService _databaseService = DatabaseService();

  List<Contador> _contadores = [];
  bool _cargando = true;
  bool _ocultarCompletados = false;

  @override
  void initState() {
    super.initState();
    // Usar vereda inicial si se proporciona
    if (widget.veredaInicial != null) {
      _veredaSeleccionada = widget.veredaInicial!;
    }
    _cargarContadores();
  }

  Future<void> _cargarContadores() async {
    setState(() => _cargando = true);

    // Ejecutar mantenimiento de registros antiguos (>15 días)
    await _databaseService.limpiarYActualizarRegistros();

    final contadores = await _databaseService.getContadores();

    if (mounted) {
      setState(() {
        _contadores = contadores;
        _cargando = false;
      });
    }
  }

  String _normalize(String text) {
    var withAccents = 'áéíóúÁÉÍÓÚäëïöüÄËÏÖÜñÑ';
    var withoutAccents = 'aeiouAEIOUaeiouAEIOUnN';
    String normalized = text;
    for (int i = 0; i < withAccents.length; i++) {
      normalized = normalized.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return normalized.toLowerCase();
  }

  List<Contador> get _contadoresFiltrados {
    final porVereda = _veredaSeleccionada == 'Todas'
        ? _contadores
        : _contadores
              .where(
                (c) =>
                    c.vereda.toUpperCase() == _veredaSeleccionada.toUpperCase(),
              )
              .toList();

    if (_searchQuery.isEmpty) {
      return _ocultarCompletados
          ? porVereda
                .where((c) => c.estado == EstadoContador.pendiente)
                .toList()
          : porVereda;
    }

    final query = _normalize(_searchQuery);
    final filtrados = porVereda.where((c) {
      final nombreNorm = _normalize(c.nombre);
      final veredaNorm = _normalize(c.vereda);
      final idNorm = _normalize(c.id);

      // Búsqueda por partes (si escribe "Juan Perez" busca que contenga ambas)
      final partes = query.split(' ').where((p) => p.isNotEmpty);
      if (partes.isEmpty) return true;

      return partes.every(
        (parte) =>
            nombreNorm.contains(parte) ||
            veredaNorm.contains(parte) ||
            idNorm.contains(parte),
      );
    }).toList();

    return _ocultarCompletados
        ? filtrados.where((c) => c.estado == EstadoContador.pendiente).toList()
        : filtrados;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
            tooltip: 'Ver Mapa',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  setState(() => _searchQuery = value);
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
                children: _veredas.map((vereda) {
                  return _buildVeredaChip(vereda);
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Contador de resultados y toggle
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
                        onChanged: (value) {
                          setState(() => _ocultarCompletados = value);
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

            const SizedBox(height: 8),

            // Lista de contadores
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _contadoresFiltrados.isEmpty
                  ? _buildEmptyState()
                  : RawScrollbar(
                      controller: _scrollController,
                      thumbColor: AppColors.primary.withValues(alpha: 0.8),
                      radius: const Radius.circular(10),
                      thickness: 4,
                      fadeDuration: const Duration(milliseconds: 500),
                      timeToFade: const Duration(milliseconds: 1000),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: _contadoresFiltrados.length,
                        itemBuilder: (context, index) {
                          final contador = _contadoresFiltrados[index];
                          return ContadorCard(
                            contador: contador,
                            onTap: () => _abrirRegistro(contador),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // FAB para exportación
      floatingActionButton: FloatingActionButton(
        heroTag: 'exportar_fab',
        onPressed: _abrirExportar,
        tooltip: 'Exportar datos',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.file_download, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron contadores',
            style: AppTextStyles.cuerpo.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeredaChip(String label) {
    final activo = _veredaSeleccionada == label;

    return GestureDetector(
      onTap: () => setState(() => _veredaSeleccionada = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.cuerpo.copyWith(
            color: activo ? Colors.white : AppColors.textPrimary,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _abrirRegistro(Contador contador) async {
    // Verificar si ya tiene lectura en el periodo activo (últimos 15 días)
    final lecturaExistente = await _databaseService.getLecturaActiva(
      contador.id,
    );

    if (lecturaExistente != null && mounted) {
      // Mostrar diálogo de detalle
      _mostrarDialogoLecturaExistente(contador, lecturaExistente);
    } else {
      // Navegar a registro
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistroLecturaScreen(
            contador: contador,
            veredaOrigen: _veredaSeleccionada,
          ),
        ),
      );
      // Recargar lista al volver
      _cargarContadores();
    }
  }

  void _mostrarDialogoLecturaExistente(Contador contador, Lectura lectura) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con color secundario (Azul)
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
                  Expanded(
                    child: Text(
                      'Lectura Registrada',
                      style: AppTextStyles.subtitulo.copyWith(
                        color: Colors.white,
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
                  Text(
                    'Este medidor ya tiene una lectura en el periodo activo.',
                    style: AppTextStyles.cuerpoSecundario,
                  ),
                  const SizedBox(height: 24),

                  // Caja unificada de detalles (Con foto y GPS)
                  InfoLecturaWidget(lectura: lectura),

                  const SizedBox(height: 32),

                  // Botones de acción
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistroLecturaScreen(
                            contador: contador,
                            lecturaExistente: lectura,
                            veredaOrigen: _veredaSeleccionada,
                          ),
                        ),
                      );
                      _cargarContadores();
                    },
                    label: const Text('EDITAR REGISTRO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _confirmarEliminarLectura(lectura),
                    label: const Text('ELIMINAR LECTURA'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirHistorial() async {
    final nuevaVereda = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistorialScreen(filtroInicial: _veredaSeleccionada),
      ),
    );

    // Si vuelve con una vereda seleccionada que existe en nuestra lista, la actualizamos
    if (nuevaVereda != null && _veredas.contains(nuevaVereda)) {
      setState(() {
        _veredaSeleccionada = nuevaVereda;
      });
    }
  }

  void _abrirExportar() {
    _abrirHistorial();
  }

  Future<void> _confirmarEliminarLectura(Lectura lectura) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta lectura?'),
        content: const Text(
          'Esta acción no se puede deshacer. Se borrará la lectura y la foto asociada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      // Cerrar el diálogo de detalles
      Navigator.pop(context);

      await _databaseService.deleteLectura(lectura.id!);
      _cargarContadores();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lectura eliminada')));
      }
    }
  }
}
