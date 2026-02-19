import 'package:asistencias_egc/models/Asistencia.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/attendance_controller.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
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
    _getEvents();
  }

  Future<void> _loadSquads() async {
    setState(() {
      _isLoading = true;
    });
    List<Escuadras> squads = await GeneralMethodsControllers.GetSquads();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId = authProvider.user!.escuadraId; // Obtener el escuadraId

    setState(() {
      if (userEscuadraId == 1 || userEscuadraId == 12) {
        escuadras = squads.where((e) => e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 14).toList();
      } else if (userEscuadraId == 2 || userEscuadraId == 13) {
        escuadras = squads.where((e) => e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 15).toList();
      } else if (userEscuadraId == 11) {
        escuadras = squads;
      } else {
        escuadras = squads.where((e) => e.escIdEscuadra == userEscuadraId).toList();
      }

      if (userEscuadraId == 11) {
        selectedEscuadra = escuadras.firstWhere(
              (e) => e.escIdEscuadra == 1,
          orElse: () => escuadras.first,
        );
      } else {
        selectedEscuadra = escuadras.firstWhere(
              (e) => e.escIdEscuadra == userEscuadraId,
          orElse: () => escuadras.first,
        );
      }

      _isLoading = false;
    });

    if (selectedEscuadra != null) {
      _loadAttendance();
    }
  }

  Future<void> _getEvents() async {
    setState(() {
      _isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId =
        selectedEscuadra?.escIdEscuadra ?? authProvider.user!.escuadraId;

    List<Event> dataList =
        await EventController.getEventsByFilters(userEscuadraId, formattedDate);

    setState(() {
      events = dataList;
      selectedEvent = (events.length > 1)
          ? events[1]
          : events.isNotEmpty
              ? events.first
              : null;
      _isLoading = false;
    });

    if (events.isEmpty) {
      setState(() {
        asistencias.clear(); // Limpiar la lista si no hay eventos disponibles
      });
    } else if (selectedEvent != null) {
      _loadAttendance(); // Ejecutar carga de asistencia si hay eventos
    }
  }

  Future<void> _loadAttendance() async {
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
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Asistencia'),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
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
                          child: DropdownButton<Escuadras>(
                            isExpanded: true,
                            value: selectedEscuadra,
                            onChanged: (Escuadras? newValue) {
                              setState(() {
                                selectedEscuadra = newValue;
                              });
                              _getEvents();
                            },
                            items: escuadras.map((escuadra) {
                              return DropdownMenuItem<Escuadras>(
                                value: escuadra,
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
                          child: DropdownButton<Event>(
                            value: selectedEvent,
                            onChanged: (Event? newValue) {
                              setState(() {
                                selectedEvent = newValue;
                              });
                              _loadAttendance(); // Llamar a función tras selección
                            },
                            items: events.map((event) {
                              return DropdownMenuItem<Event>(
                                value: event,
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: size.width,
                    child: Text('Total: ${asistencias.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: size.width,
                    child: Text(
                        'Asistencia: ${asistencias.where((a) => a.asistencia == 1).length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                  SizedBox(
                    width: size.width,
                    child: Text(
                        'Faltantes: ${asistencias.where((a) => a.asistencia == 0).length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                  const SizedBox(height: 20),
                  attendanceTable(asistencias),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }
}

Widget attendanceTable(List<Asistencia> attendance) {
  return Expanded(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Scroll horizontal para evitar desbordamiento
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 30, // Más espacio entre columnas
          headingRowColor:
              WidgetStateProperty.resolveWith((states) => Colors.black),
          columns: const [
            DataColumn(
              label: Text(
                "Asistencia",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Nombre",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Apellido",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Fecha",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: attendance.map((asistencia) {
            return DataRow(cells: [
              DataCell(
                Center(
                  child: Icon(
                    asistencia.asistencia == 1
                        ? Icons.check_circle
                        : Icons.cancel,
                    color:
                        asistencia.asistencia == 1 ? Colors.green : Colors.red,
                  ),
                ),
              ),
              DataCell(Text(asistencia.intNombres)),
              DataCell(Text(asistencia.intApellidos)),
              DataCell(Text(
                asistencia.asiFechaAsistencia != null
                    ? DateFormat('dd-MM-yyyy hh:mm')
                        .format(DateTime.parse(asistencia.asiFechaAsistencia!))
                    : "--/--/----", // Si es null, espacio en blanco
              )),
            ]);
          }).toList(),
        ),
      ),
    ),
  );
}
