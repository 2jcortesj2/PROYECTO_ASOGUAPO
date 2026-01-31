import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/lectura.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/info_lectura_widget.dart';

/// Pantalla de historial y exportación de lecturas
class HistorialScreen extends StatefulWidget {
  final String? filtroInicial;

  const HistorialScreen({super.key, this.filtroInicial});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final ScrollController _scrollController = ScrollController();
  String _filtroActivo = 'Todas';
  final List<String> _veredas = [
    'El Recreo',
    'Pueblo Nuevo',
    'El Tendido',
    'Todas',
  ];

  final DatabaseService _databaseService = DatabaseService();
  final ExportService _exportService = ExportService();

  List<Lectura> _lecturas = [];
  bool _cargando = true;
  bool _exportando = false;
  bool _cancelarExportacion = false;
  int _segundosExportando = 0;
  Timer? _exportTimer;
  ExportProgress? _progresoActual;

  @override
  void initState() {
    super.initState();
    _cargarLecturas();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _exportTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarLecturas() async {
    setState(() => _cargando = true);
    final lecturas = await _databaseService.getLecturas();

    if (mounted) {
      setState(() {
        _lecturas = lecturas;

        // Determinar qué vereda seleccionar
        if (widget.filtroInicial != null) {
          // Si nos pasaron un filtro inicial, lo usamos
          _filtroActivo = _veredas.firstWhere(
            (v) => v.toUpperCase() == widget.filtroInicial!.toUpperCase(),
            orElse: () => 'Todas',
          );
        } else if (_lecturas.isNotEmpty) {
          // Si no hay filtro inicial pero hay lecturas, usamos la última
          final ultimaVereda = _lecturas.first.vereda;
          _filtroActivo = _veredas.firstWhere(
            (v) => v.toUpperCase() == ultimaVereda.toUpperCase(),
            orElse: () => 'Todas',
          );
        } else {
          _filtroActivo = 'Todas';
        }

        _cargando = false;
      });
    }
  }

  List<Lectura> get _lecturasFiltradas {
    if (_filtroActivo == 'Todas') return _lecturas;

    return _lecturas.where((l) {
      return l.vereda.toUpperCase() == _filtroActivo.toUpperCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Lecturas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _filtroActivo),
        ),
      ),
      body: PopScope(
        canPop: !_exportando, // Bloquear volver si está exportando
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (context.mounted) {
            Navigator.pop(context, _filtroActivo);
          }
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
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

                const SizedBox(height: 16),

                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                  ),
                  child: Row(
                    children: _veredas.map((v) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFiltroChip(v),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de lecturas
                Expanded(
                  child: _cargando
                      ? const Center(child: CircularProgressIndicator())
                      : _lecturasFiltradas.isEmpty
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
                            itemCount: _lecturasFiltradas.length,
                            itemBuilder: (context, index) {
                              return _buildLecturaCard(
                                _lecturasFiltradas[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),

            // Overlay de progreso
            if (_exportando)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          _progresoActual?.mensaje ?? 'Procesando...',
                          style: AppTextStyles.subtitulo,
                          textAlign: TextAlign.center,
                        ),
                        if (_progresoActual?.tamanoEstimado != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tamaño: ${_progresoActual!.tamanoEstimado} | Quedan: ${_progresoActual!.tiempoRestante}',
                            style: AppTextStyles.cuerpoSecundario.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: _progresoActual?.porcentaje ?? 0,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${((_progresoActual?.porcentaje ?? 0) * 100).toInt()}%',
                          style: AppTextStyles.cuerpo.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        // Botón de cancelar después de 5 segundos
                        if (_segundosExportando >= 5) ...[
                          const SizedBox(height: 24),
                          TextButton.icon(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.orange,
                            ),
                            label: const Text(
                              'CANCELAR EXPORTACIÓN',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _cancelarExportacion = true;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
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
            onPressed: (_lecturasFiltradas.isEmpty || _exportando)
                ? null
                : _exportarDatos,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalleLectura(lectura),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // Miniatura
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      lectura.fotoPath.isNotEmpty &&
                          File(lectura.fotoPath).existsSync()
                      ? Image.file(
                          File(lectura.fotoPath),
                          fit: BoxFit.cover,
                          cacheWidth:
                              120, // Optimización para móviles de baja gama
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.image, color: Colors.grey, size: 30),
                ),
              ),

              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lectura.nombreUsuario,
                      style: AppTextStyles.cardTitulo,
                    ),
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
              // Icono indicador de "ver más"
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleLectura(Lectura lectura) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          lectura.nombreUsuario,
          style: AppTextStyles.subtitulo,
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: InfoLecturaWidget(lectura: lectura),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
        ],
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
            _filtroActivo == 'Todas'
                ? 'Selecciona una vereda para exportar'
                : 'No hay lecturas en este período',
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
              title: const Text('Solo reporte CSV'),
              subtitle: const Text('Compatible con Excel (datos)'),
              onTap: () => _ejecutarExportacion(TipoExportacion.csv),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: Colors.orange),
              ),
              title: const Text('Solo fotos (ZIP)'),
              subtitle: const Text('Comprimido con todas las evidencias'),
              onTap: () => _ejecutarExportacion(TipoExportacion.zip),
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
                child: const Icon(
                  Icons.all_inclusive,
                  color: AppColors.secondary,
                ),
              ),
              title: const Text('Exportar TODO'),
              subtitle: const Text('CSV y fotos al mismo tiempo'),
              onTap: () => _ejecutarExportacion(TipoExportacion.todo),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _ejecutarExportacion(TipoExportacion tipo) async {
    Navigator.pop(context);

    setState(() {
      _exportando = true;
      _progresoActual = null;
      _cancelarExportacion = false;
      _segundosExportando = 0;
    });

    // Iniciar timer para dar opción de cancelar después de 5s
    _exportTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _segundosExportando = timer.tick;
        });
      }
    });

    try {
      await _exportService.exportarLecturas(
        lecturasFiltradas: _lecturasFiltradas,
        veredaFiltro: _filtroActivo,
        tipo: tipo,
        onProgress: (progreso) {
          if (mounted) {
            setState(() {
              _progresoActual = progreso;
            });
          }
        },
        checkCancel: () => _cancelarExportacion,
      );
    } catch (e) {
      if (mounted && !_cancelarExportacion) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _exportTimer?.cancel();
      if (mounted) {
        setState(() {
          _exportando = false;
        });

        if (_cancelarExportacion) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exportación cancelada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }
}
