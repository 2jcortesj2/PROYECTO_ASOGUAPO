import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/lectura.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../widgets/boton_principal.dart';

/// Pantalla de historial y exportación de lecturas
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String _filtroActivo = 'Hoy';

  final DatabaseService _databaseService = DatabaseService();
  final ExportService _exportService = ExportService();

  List<Lectura> _lecturas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarLecturas();
  }

  Future<void> _cargarLecturas() async {
    setState(() => _cargando = true);
    final lecturas = await _databaseService.getLecturas();
    if (mounted) {
      setState(() {
        _lecturas = lecturas;
        _cargando = false;
      });
    }
  }

  List<Lectura> get _lecturasFiltradas {
    final ahora = DateTime.now();
    final hoyInicio = DateTime(ahora.year, ahora.month, ahora.day);

    switch (_filtroActivo) {
      case 'Hoy':
        return _lecturas.where((l) => l.fecha.isAfter(hoyInicio)).toList();
      case 'Semana':
        final semanaInicio = hoyInicio.subtract(const Duration(days: 7));
        return _lecturas.where((l) => l.fecha.isAfter(semanaInicio)).toList();
      case 'Mes':
      default:
        return _lecturas;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Lecturas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtítulo
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Text(
              '${_lecturasFiltradas.length} lecturas registradas',
              style: AppTextStyles.cuerpoSecundario,
            ),
          ),

          const SizedBox(height: 12),

          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                _buildFiltroChip('Hoy'),
                const SizedBox(width: 8),
                _buildFiltroChip('Semana'),
                const SizedBox(width: 8),
                _buildFiltroChip('Mes'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de lecturas
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _lecturasFiltradas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: _lecturasFiltradas.length,
                    itemBuilder: (context, index) {
                      return _buildLecturaCard(_lecturasFiltradas[index]);
                    },
                  ),
          ),
        ],
      ),

      // Botón exportar fijo abajo
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BotonPrincipal(
            texto: 'EXPORTAR DATOS',
            icono: Icons.file_download,
            onPressed: _exportarDatos,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String label) {
    final activo = _filtroActivo == label;

    return GestureDetector(
      onTap: () => setState(() => _filtroActivo = label),
      child: Container(
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

  Widget _buildLecturaCard(Lectura lectura) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // Miniatura
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),

            const SizedBox(width: 16),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lectura.nombreUsuario, style: AppTextStyles.cardTitulo),
                  const SizedBox(height: 4),
                  Text(
                    lectura.lecturaFormateada,
                    style: AppTextStyles.subtitulo.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lectura.fechaFormateada,
                    style: AppTextStyles.cardSubtitulo.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay lecturas en este período',
            style: AppTextStyles.cuerpo.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _exportarDatos() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('Exportar Lecturas', style: AppTextStyles.subtitulo),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_chart, color: AppColors.primary),
              ),
              title: const Text('Exportar como CSV'),
              subtitle: const Text('Compatible con Excel'),
              onTap: () {
                _simularExportacion('CSV');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.share, color: AppColors.secondary),
              ),
              title: const Text('Compartir'),
              subtitle: const Text('Enviar por WhatsApp, Email...'),
              onTap: () {
                _simularExportacion('Compartir');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _simularExportacion(String tipo) async {
    Navigator.pop(context); // Cerrar modal si no se cerró antes

    try {
      if (tipo == 'CSV') {
        await _exportService.exportarLecturas();
      } else {
        // Reutilizamos la misma lógica
        await _exportService.exportarLecturas();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Archivo generado exitosamente'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
