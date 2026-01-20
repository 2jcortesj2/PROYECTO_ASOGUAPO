import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/contador.dart';
import '../widgets/contador_card.dart';
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

  // Datos de prueba para el prototipo con Veredas reales
  final List<Contador> _contadores = [
    const Contador(
      id: '1',
      nombre: 'Juan Pérez García',
      vereda: 'El Recreo',
      lote: 'Lote 45',
      ultimaLectura: 1234,
      estado: EstadoContador.registrado,
    ),
    const Contador(
      id: '2',
      nombre: 'María Rodríguez López',
      vereda: 'El Tendido',
      lote: 'Lote 12',
      ultimaLectura: 1120,
      estado: EstadoContador.pendiente,
    ),
    const Contador(
      id: '3',
      nombre: 'Carlos Sánchez Ruiz',
      vereda: 'Pueblo Nuevo',
      lote: 'Lote 88',
      ultimaLectura: 1350,
      estado: EstadoContador.registrado,
    ),
    const Contador(
      id: '4',
      nombre: 'Ana Martínez Flores',
      vereda: 'El Recreo',
      lote: 'Lote 30',
      ultimaLectura: 1210,
      estado: EstadoContador.pendiente,
    ),
    const Contador(
      id: '5',
      nombre: 'Pedro González Díaz',
      vereda: 'El Tendido',
      lote: 'Lote 67',
      ultimaLectura: 980,
      estado: EstadoContador.conError,
    ),
    const Contador(
      id: '6',
      nombre: 'Lucía Hernández Castro',
      vereda: 'Pueblo Nuevo',
      lote: 'Lote 23',
      ultimaLectura: 1567,
      estado: EstadoContador.pendiente,
    ),
  ];

  List<Contador> get _contadoresFiltrados {
    final porVereda = _contadores
        .where((c) => c.vereda == _veredaSeleccionada)
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
                  final seleccionada = _veredaSeleccionada == vereda;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(vereda),
                      selected: seleccionada,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _veredaSeleccionada = vereda);
                        }
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: seleccionada
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: seleccionada
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
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
              child: _contadoresFiltrados.isEmpty
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

  void _abrirRegistro(Contador contador) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroLecturaScreen(contador: contador),
      ),
    );
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
