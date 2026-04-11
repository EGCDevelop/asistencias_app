import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/attendance_controller.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipationHistory extends StatefulWidget {
  const ParticipationHistory({super.key});

  @override
  State<ParticipationHistory> createState() => _ParticipationHistoryState();
}

class _ParticipationHistoryState extends State<ParticipationHistory> {
  List<Escuadras> squads = [];
  Escuadras? squadSelected;

  bool _isLoading = false;

  List<Map<String, dynamic>> matrixData = [];
  int memberType = 2;
  int position = 0;
  DateTime startDate = DateTime(2026, 1, 1);

  int _currentPage = 0;
  final int _pageSize = 12;

  // Obtener las columnas de eventos dinámicamente
  List<String> get _eventColumns {
    if (matrixData.isEmpty) return [];
    return matrixData.first.keys
        .where((key) =>
            key != "Escuadra" &&
            key != "Puesto" &&
            key != "NombreCompleto" &&
            key != "Asistio" &&
            key != "Falta" &&
            key != "Tarde" &&
            key != "Permisos" &&
            key != "NA")
        .toList();
  }

  // Obtener los datos paginados
  List<Map<String, dynamic>> get _paginatedData {
    int start = _currentPage * _pageSize;
    int end = start + _pageSize;
    if (start >= matrixData.length) return [];
    return matrixData.sublist(
        start, end > matrixData.length ? matrixData.length : end);
  }

  final List<Map<String, dynamic>> news = [
    {"id": 2, "name": "Todos"},
    {"id": 1, "name": "Nuevo"},
    {"id": 0, "name": "Antiguos"}
  ];

  final List<Map<String, dynamic>> positionsList = [
    {"id": 0, "name": "Todos"},
    {"id": 1, "name": "Comandantes"},
    {"id": 8, "name": "Integrantes"}
  ];

  @override
  void initState() {
    super.initState();
    _initDate();
  }

  Future<void> _initDate() async {
    await _loadSquads();
    await _loadMatriz();
  }

  Future<void> _loadSquads() async {
    setState(() {
      _isLoading = true;
    });

    List<Escuadras> response = await GeneralMethodsControllers.GetSquads();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId = authProvider.user!.escuadraId;

    setState(() {
      if (userEscuadraId == 1 || userEscuadraId == 12) {
        squads = response
            .where((e) =>
                e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 14)
            .toList();
      } else if (userEscuadraId == 2 || userEscuadraId == 13) {
        squads = response
            .where((e) =>
                e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 15)
            .toList();
      } else if (userEscuadraId == 11) {
        Escuadras general =
            Escuadras(escIdEscuadra: 11, escNombre: "Generales");
        squads.add(general);
        squads = response;
      } else {
        squads =
            response.where((e) => e.escIdEscuadra == userEscuadraId).toList();
      }

      if (userEscuadraId == 11) {
        squadSelected = response.firstWhere(
          (e) => e.escIdEscuadra == 1,
          orElse: () => response.first,
        );
      } else {
        squadSelected = response.firstWhere(
          (e) => e.escIdEscuadra == userEscuadraId,
          orElse: () => response.first,
        );
      }

      _isLoading = false;
    });
  }

  Future<void> _loadMatriz() async {
    setState(() => _isLoading = true);

    try {
      final data = await AttendanceController.getMatrizAsistencia(
          squadId: squadSelected?.escIdEscuadra ?? 0,
          memberType: memberType,
          position: position,
          startDate: startDate);

      setState(() {
        matrixData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Mostrar SnackBar de error si deseas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Historial de Asistencias'),
            body: RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.black,
              onRefresh: _loadMatriz,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Escuadra",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: DropdownButton<Escuadras>(
                                          isExpanded: true,
                                          value: squadSelected,
                                          onChanged: (Escuadras? newValue) {
                                            setState(() {
                                              squadSelected = newValue;
                                            });
                                            _loadMatriz();
                                          },
                                          items: squads.map((esc) {
                                            return DropdownMenuItem<Escuadras>(
                                              value: esc,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  esc.escNombre,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                          dropdownColor: Colors.black,
                                          underline: Container(),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Estado",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          value: memberType,
                                          onChanged: (int? value) {
                                            setState(() {
                                              memberType = value!;
                                            });
                                            _loadMatriz();
                                          },
                                          items: news.map((newsItem) {
                                            return DropdownMenuItem<int>(
                                              value: newsItem["id"],
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  newsItem["name"],
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                          dropdownColor: Colors.black,
                                          underline: Container(),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Puesto",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          value: position,
                                          onChanged: (int? value) {
                                            setState(() {
                                              position = value!;
                                            });
                                            _loadMatriz();
                                          },
                                          items: positionsList.map((newsItem) {
                                            return DropdownMenuItem<int>(
                                              value: newsItem["id"],
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  newsItem["name"],
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                          dropdownColor: Colors.black,
                                          underline: Container(),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (matrixData.isNotEmpty) ...[
                        _buildAttendanceLegend(),
                        _buildTable(),
                        _buildPaginationControls(),
                      ] else if (!_isLoading)
                        const Text("No hay datos disponibles",
                            style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }

  Widget _buildTable() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COLUMNA FIJA: Nombres
        _buildFixedColumn(),
        // COLUMNAS MÓVILES: Eventos
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildScrollableColumns(),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedColumn() {
    return Container(
      width: 150,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCell("Nombre", isHeader: true, color: Colors.white),
          ..._paginatedData.map((row) => _buildCell(
                row["NombreCompleto"],
                isHeader: false,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  Widget _buildScrollableColumns() {
    // Definimos un ancho estándar para las columnas de totales
    const double totalWidth = 70.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- FILA DE ENCABEZADOS (HEADERS) ---
        Row(
          children: [
            //Los 4 encabezados de totales primero
            _buildCell("Asist.",
                isHeader: true, width: totalWidth, color: Colors.green),
            _buildCell("Tard.",
                isHeader: true, width: totalWidth, color: Colors.orange),
            _buildCell("Perm.",
                isHeader: true, width: totalWidth, color: Colors.blueAccent),
            _buildCell("Falt.",
                isHeader: true, width: totalWidth, color: Colors.red),
            _buildCell("N/A",
                isHeader: true, width: totalWidth, color: Colors.grey),

            //Luego los nombres de los eventos dinámicos
            ..._eventColumns
                .map((e) => _buildCell(e, isHeader: true, width: 120)),
          ],
        ),

        // --- FILAS DE DATOS (BODY) ---
        ..._paginatedData.map((row) {
          return Row(
            children: [
              //Los 4 valores de totales (sacados del SP)
              _buildCell(row["Asistio"]?.toString() ?? "0",
                  width: totalWidth, isHeader: true),
              _buildCell(row["Tarde"]?.toString() ?? "0",
                  width: totalWidth, isHeader: true),
              _buildCell(row["Permisos"]?.toString() ?? "0",
                  width: totalWidth, isHeader: true),
              _buildCell(row["Falta"]?.toString() ?? "0",
                  width: totalWidth, isHeader: true),
              _buildCell(row["NA"]?.toString() ?? "0",
                  width: totalWidth, isHeader: true),

              //Luego los iconos de estado de los eventos
              ..._eventColumns.map((event) => _buildStatusCell(row[event])),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCell(String text,
      {bool isHeader = false, double width = 150, Color? color}) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC2CBD4), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? const Color(0xFF313852),
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell(dynamic status) {
    IconData icon;
    Color iconColor;

    switch (status.toString()) {
      case '1': // Asistió
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case '2': // No asistió
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case '3': // N/A (Solo comandantes)
        icon = Icons.remove_circle_outline;
        iconColor = Colors.grey;
        break;
      case '5': // Tarde
        icon = Icons.flag;
        iconColor = Colors.blueAccent;
        break;
      default:
        icon = Icons.help_outline;
        iconColor = Colors.blueGrey;
    }

    return Container(
      width: 120,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC2CBD4), width: 0.5),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = (matrixData.length / _pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(
            icon: Icons.arrow_back_ios_new,
            isEnabled: _currentPage > 0,
            onTap: () => setState(() => _currentPage--),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "Página",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 10),
                ),
                Text(
                  "${_currentPage + 1} de $totalPages",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildNavButton(
            icon: Icons.arrow_forward_ios,
            isEnabled: _currentPage < totalPages - 1,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFF313852)
              : Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.white24,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAttendanceLegend() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF313852),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            "REFERENCIA DE ASISTENCIA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legendItemVertical(Icons.check_circle, Colors.green, "Asistió"),
              _legendItemVertical(Icons.watch_later, Colors.orange, "Tarde"),
              _legendItemVertical(Icons.flag, Colors.blueAccent, "Permiso"),
              _legendItemVertical(Icons.cancel, Colors.red, "Falta"),
              _legendItemVertical(
                  Icons.remove_circle_outline, Colors.grey, "N/A"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItemVertical(IconData icon, Color color, String label) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
