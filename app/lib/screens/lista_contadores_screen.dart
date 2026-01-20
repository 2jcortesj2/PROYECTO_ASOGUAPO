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
  const ListaContadoresScreen({super.key});

  @override
  State<ListaContadoresScreen> createState() => _ListaContadoresScreenState();
}

class _ListaContadoresScreenState extends State<ListaContadoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _veredaSeleccionada = 'El Recreo';
  final List<String> _veredas = ['El Recreo', 'Pueblo Nuevo', 'El Tendido'];
  final DatabaseService _databaseService = DatabaseService();

  List<Contador> _contadores = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarContadores();
  }

  Future<void> _cargarContadores() async {
    setState(() => _cargando = true);
    final contadores = await _databaseService.getContadores();

    if (mounted) {
      setState(() {
        _contadores = contadores;
        _cargando = false;
      });
    }
  }

  List<Contador> get _contadoresFiltrados {
    final porVereda = _contadores
        .where(
          (c) => c.vereda.toUpperCase() == _veredaSeleccionada.toUpperCase(),
        )
        .toList();

    if (_searchQuery.isEmpty) return porVereda;

    final query = _searchQuery.toLowerCase();
    return porVereda.where((c) {
      return c.nombre.toLowerCase().contains(query) ||
          c.vereda.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lecturas del Día', style: AppTextStyles.titulo),
                  const SizedBox(height: 4),
                  Text(fechaHoy, style: AppTextStyles.cuerpoSecundario),
                ],
              ),
            ),

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

            // Contador de resultados
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Text(
                '${_contadoresFiltrados.length} contadores',
                style: AppTextStyles.cuerpoSecundario,
              ),
            ),

            const SizedBox(height: 8),

            // Lista de contadores
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _contadoresFiltrados.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
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
    // Verificar si ya tiene lectura hoy
    final lecturaExistente = await _databaseService.getLecturaPorContadorHoy(
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
          builder: (context) => RegistroLecturaScreen(contador: contador),
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
            Text('Usuario ya registrado', style: AppTextStyles.subtitulo),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.registrado.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.registrado.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.registrado),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lectura registrada para hoy',
                      style: AppTextStyles.cuerpo.copyWith(
                        color: AppColors.registrado,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDetalleRow(Icons.speed, 'Lectura', lectura.lecturaFormateada),
            const Divider(height: 16),
            _buildDetalleRow(
              Icons.calendar_today,
              'Fecha',
              '${lectura.fecha.day} ${_obtenerMes(lectura.fecha.month)} ${lectura.fecha.year}',
            ),
            const Divider(height: 16),
            _buildDetalleRow(
              Icons.access_time,
              'Hora',
              '${lectura.fecha.hour.toString().padLeft(2, '0')}:${lectura.fecha.minute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 24),
          ],
        ),
        actions: [
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
                  ),
                ),
              );
              _cargarContadores();
            },
            label: const Text('CORREGIR / EDITAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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

  void _abrirHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistorialScreen()),
    );
  }

  void _abrirExportar() {
    // Por ahora redirigimos al historial que tiene la lógica de exportar
    // o podríamos abrir el modal directamente aquí.
    _abrirHistorial();
  }
}
