import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/contador.dart';
import '../models/lectura.dart';
import '../widgets/contador_card.dart';
import '../services/database_service.dart';
import 'registro_lectura_screen.dart';
import 'historial_screen.dart';

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

    final query = _searchQuery.toLowerCase();
    final filtrados = porVereda.where((c) {
      return c.nombre.toLowerCase().contains(query) ||
          c.vereda.toLowerCase().contains(query);
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
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lectura en periodo activo', style: AppTextStyles.subtitulo),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleRow(Icons.speed, 'Lectura', lectura.lecturaFormateada),
            const SizedBox(height: 12),
            _buildDetalleRow(
              Icons.calendar_today,
              'Fecha',
              '${lectura.fecha.day} ${_obtenerMes(lectura.fecha.month)} ${lectura.fecha.year}',
            ),
            const SizedBox(height: 12),
            _buildDetalleRow(
              Icons.access_time,
              'Hora',
              '${lectura.fecha.hour.toString().padLeft(2, '0')}:${lectura.fecha.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () async {
                    Navigator.pop(context); // Cerrar diálogo
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
                  label: const Text('CORREGIR / EDITAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _confirmarEliminarLectura(lectura),
                  label: const Text('ELIMINAR REGISTRO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: AppTextStyles.cuerpo.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  String _obtenerMes(int month) {
    const meses = [
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
    return meses[month];
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
