import 'package:asistencias_egc/models/Asistencia.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/attendance_controller.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
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
    List<Escuadras> squads = await GeneralMethodsControllers.GetSquads();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId = authProvider.user!.escuadraId; // Obtener el escuadraId

    setState(() {
      escuadras = squads;
      selectedEscuadra = escuadras
          .firstWhere((escuadra) => escuadra.escIdEscuadra == userEscuadraId);
      _isLoading = false;
    });

    if (selectedEscuadra != null) {
      _loadAsistencia();
    }
  }

  Future<void> _loadAsistencia() async {
    if (selectedEscuadra == null) return;

    setState(() => _isLoading = true);

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    asistencias = await AttendanceController.getAsistencia(
        selectedEscuadra!.escIdEscuadra, formattedDate);

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
      _loadAsistencia();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var authProvider = Provider.of<AuthProvider>(context);
    int position = authProvider.user!.puestoId;

    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            appBar: AppBar(title: const Text("Asistencia")),
            body: Hero(
              tag: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
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
                            style: const TextStyle(
                                color: Colors.white), // Letras en blanco
                          ),
                        ),
                        //SizedBox(width: size.width * 0.1,),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black, // Fondo negro
                            borderRadius:
                                BorderRadius.circular(5), // Bordes redondeados
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<Escuadras>(
                            value: selectedEscuadra,
                            onChanged: (position != 1 ||
                                    position != 2 ||
                                    position != 3 ||
                                    position != 4)
                                ? null
                                : (Escuadras? newValue) {
                                    setState(() => selectedEscuadra = newValue);
                                    _loadAsistencia();
                                  },
                            items: escuadras.map((escuadra) {
                              return DropdownMenuItem<Escuadras>(
                                value: escuadra,
                                child: Text(
                                  escuadra.escNombre,
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
              MaterialStateProperty.resolveWith((states) => Colors.black),
          columns: const [
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
            DataColumn(
              label: Text(
                "Asistencia",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: attendance.map((asistencia) {
            return DataRow(cells: [
              DataCell(Text(asistencia.intNombres)),
              DataCell(Text(asistencia.intApellidos)),
              DataCell(Text(
                asistencia.asiFechaAsistencia != null
                    ? DateFormat('dd-MM-yyyy hh:mm')
                        .format(DateTime.parse(asistencia.asiFechaAsistencia!))
                    : "--/--/----", // Si es null, espacio en blanco
              )),
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
            ]);
          }).toList(),
        ),
      ),
    ),
  );
}
