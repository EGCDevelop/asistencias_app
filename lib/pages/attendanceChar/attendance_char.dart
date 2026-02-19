import 'package:asistencias_egc/models/Asistencia.dart';
import 'package:asistencias_egc/models/AttendanceChartDTO.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/attendance_char_controller.dart';
import 'package:asistencias_egc/utils/api/attendance_controller.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AttendanceChar extends StatefulWidget {
  const AttendanceChar({super.key});

  @override
  State<AttendanceChar> createState() => _AttendanceCharState();
}

class _AttendanceCharState extends State<AttendanceChar> {
  Color greenColor = const Color(0xFF006414);
  Color redColor = const Color(0xFFD31900);
  Color blueColor = const Color(0xFF1465bb);

  List<AttendanceChartDTO> chartData = [];
  List<Escuadras> escuadras = [];
  List<Asistencia> asistencias = [];
  Escuadras? selectedEscuadra;
  List<Event> events = [];
  Event? selectedEvent;
  bool _isLoading = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSquads();
  }

  Future<void> _loadSquads() async {
    setState(() {
      _isLoading = true;
    });

    // 1. Cargamos las escuadras primero
    List<Escuadras> squads = await GeneralMethodsControllers.GetSquads();
    squads.insert(
      0,
      Escuadras(
        escIdEscuadra: 0,
        escNombre: 'Todas',
      ),
    );
    setState(() {
      escuadras = squads;
      selectedEscuadra = escuadras.first;
    });

    // 2. IMPORTANTE: Esperamos a que los eventos terminen de cargar antes de quitar el loading
    await _getEvents();
  }

  Future<void> _getEvents() async {
    setState(() {
      _isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    var authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Determinamos el ID de búsqueda inicial
    int userEscuadraId = selectedEscuadra?.escIdEscuadra ?? authProvider.user!.escuadraId;
    userEscuadraId = userEscuadraId == 0 ? authProvider.user!.escuadraId : userEscuadraId;

    List<Event> dataList = await EventController.getEventsByFilters(userEscuadraId, formattedDate);

    setState(() {
      events = dataList;
      if (events.isNotEmpty) {
        // Si ya tenemos un evento seleccionado, intentamos mantener la versión "completa"
        // que ya teníamos para no perder el listado de escuadras original.
        bool sigueExistiendo = events.any((e) => e.eveId == selectedEvent?.eveId);

        if (selectedEvent == null || !sigueExistiendo) {
          selectedEvent = (events.length > 1) ? events[1] : events.first;
        }

        // Sincronizar escuadra solo si es necesario [cite: 18]
        if (selectedEvent?.eveBandaGeneral == 0) {
          List<int> ids = selectedEvent!.idsEscuadras;
          if (!ids.contains(selectedEscuadra?.escIdEscuadra)) {
            selectedEscuadra = escuadras.firstWhere(
                  (esc) => ids.contains(esc.escIdEscuadra),
              orElse: () => escuadras.first,
            );
          }
        }
      } else {
        selectedEvent = null;
        asistencias.clear();
      }
      _isLoading = false;
    });

    // 3. Cargamos los datos finales de la gráfica y asistencia
    if (selectedEvent != null) {
      _loadAsistencia();

      List<AttendanceChartDTO> data = await AttendanceCharController.getChartData(
        context,
        selectedEvent!.eveId,
        selectedEscuadra?.escIdEscuadra ?? 0,
      );

      setState(() {
        chartData = data;
      });
    }
  }

  Future<void> _loadAsistencia() async {
    if (selectedEscuadra == null || events.isEmpty) {
      setState(() {
        asistencias.clear(); // Limpiar la lista si no hay eventos
      });
      return;
    }

    setState(() => _isLoading = true);

    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    int eventId = selectedEvent?.eveId ?? 0;
    int userEscuadraId =
        selectedEscuadra?.escIdEscuadra ?? authProvider.user!.escuadraId;

    asistencias = await AttendanceController.getAsistencia(
        userEscuadraId, formattedDate, eventId);

    setState(() => _isLoading = false);
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Bordes redondeados
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Color de los elementos principales
              onPrimary: Colors.white, // Color del texto en el encabezado
              onSurface: Colors.black, // Color del texto en la selección
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      _getEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    int position = authProvider.user!.puestoId;

    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Gráficas'),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Fondo negro
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5), // Bordes redondeados
                          ),
                        ),
                        onPressed: () => _selectDate(context),
                        child: Text(
                          "Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                            DropdownButton<int>(
                              value: selectedEvent?.eveId,
                              onChanged: (int? newId) {
                                if (newId != null) {
                                  setState(() {
                                    selectedEvent = events.firstWhere((e) => e.eveId == newId);
                                  });
                                  _loadAsistencia();
                                }
                              },
                              items: events.map((event) {
                                return DropdownMenuItem<int>(
                                  value: event.eveId,
                                  child: Text(
                                    event.eveTitulo,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              style: const TextStyle(color: Colors.white),
                              dropdownColor: Colors.black,
                              underline: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                            DropdownButton<int>(
                              isExpanded: true,
                              value: selectedEscuadra?.escIdEscuadra,
                              onChanged: (position < 5)
                                  ? (int? newId) {
                                if (newId != null) {
                                  setState(() {
                                    selectedEscuadra = escuadras.firstWhere((esc) => esc.escIdEscuadra == newId);
                                  });
                                  _getEvents();
                                }
                              }
                                  : null,
                              // Busca el items: escuadras.where en la línea 79 de tu código
                              items: escuadras.where((esc) {
                                // 1. "Todas" siempre visible
                                if (esc.escIdEscuadra == 0) return true;

                                // 2. Si no hay evento o es Banda General, mostrar TODAS las escuadras cargadas
                                // Esto evita que al filtrar por una, las demás desaparezcan
                                if (selectedEvent == null || selectedEvent!.eveBandaGeneral == 1) return true;

                                // 3. Si es restringido, mostrar solo las permitidas por el evento original
                                return selectedEvent!.idsEscuadras.contains(esc.escIdEscuadra);
                              }).map((escuadra) {
                                return DropdownMenuItem<int>(
                                  value: escuadra.escIdEscuadra,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      escuadra.escNombre,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }).toList(),
                              style: const TextStyle(color: Colors.white),
                              dropdownColor: Colors.black,
                              underline: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    const SizedBox(height: 20),
                    buildPieChart(),
                    buildProgressBarRows()
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }

  Widget buildPieChart() {
    // Calcular totales desde los datos
    int totalAsistencias =
        chartData.fold(0, (sum, item) => sum + item.asistencias);
    int totalFaltas = chartData.fold(0, (sum, item) => sum + item.faltan);
    int totalIntegrantes =
        chartData.fold(0, (sum, item) => sum + item.totalIntegrantes);

    int total = totalAsistencias + totalFaltas;

    // Si no hay datos, mostrar mensaje
    if (total == 0) {
      return const Center(
        child: Text("No hay datos para mostrar la gráfica."),
      );
    }

    // Función para calcular porcentaje
    double porcentaje(double valor) => (valor / total * 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título y total de integrantes con ícono
          const Column(
            children: [
              Text(
                "TOTAL EGC",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: greenColor,
                        value: totalAsistencias.toDouble(),
                        title:
                            '${porcentaje(totalAsistencias.toDouble()).toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 60,
                        titlePositionPercentageOffset: 0.6,
                      ),
                      PieChartSectionData(
                        color: redColor,
                        value: totalFaltas.toDouble(),
                        title:
                            '${porcentaje(totalFaltas.toDouble()).toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 60,
                        titlePositionPercentageOffset: 0.6,
                      ),
                    ],
                  ),
                ),
                // Ícono centrado encima del gráfico
                Image.asset(
                  'assets/escudo.png',
                  width: 50,
                  height: 50,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLegendRow(
                color: greenColor,
                label: 'Asistencias',
                value: totalAsistencias,
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                color: redColor,
                label: 'Faltas',
                value: totalFaltas,
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                color: blueColor,
                label: 'Total',
                value: totalAsistencias + totalFaltas,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required int value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: const BoxDecoration(
            border: BorderDirectional(
                bottom: BorderSide(color: Color(0xFFE4E4E5)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ícono + Label alineados a la izquierda
            Row(
              children: [
                Icon(
                  Icons.hexagon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
            // Valor alineado a la derecha
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressBarRows() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              "Resumen",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ...chartData.map((item) {
            double asistenciaPct = item.totalIntegrantes > 0
                ? item.asistencias / item.totalIntegrantes
                : 0;
            double faltaPct = item.totalIntegrantes > 0
                ? item.faltan / item.totalIntegrantes
                : 0;
            double completado = asistenciaPct * 100;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre escuadra
                Text(
                  item.escNombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Chips A y F
                Row(
                  children: [
                    _infoChip("A: ${item.asistencias}", greenColor),
                    const SizedBox(width: 6),
                    _infoChip("F: ${item.faltan}", redColor),
                  ],
                ),
                const SizedBox(height: 8),

                // Barra proporcional + porcentaje
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: (asistenciaPct * 100).round(),
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: greenColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: (faltaPct * 100).round(),
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: redColor,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${completado.toStringAsFixed(0)}%",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
