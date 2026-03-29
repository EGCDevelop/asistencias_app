import 'dart:typed_data';
import 'package:asistencias_egc/models/Asistencia.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/attendance_controller.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/CustomTextField.dart';
import 'package:asistencias_egc/widgets/GenericDialog.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/CustomSnackBar.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
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
    int userEscuadraId = authProvider.user!.escuadraId;

    setState(() {
      if (userEscuadraId == 1 || userEscuadraId == 12) {
        escuadras = squads
            .where((e) =>
                e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 14)
            .toList();
      } else if (userEscuadraId == 2 || userEscuadraId == 13) {
        escuadras = squads
            .where((e) =>
                e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 15)
            .toList();
      } else if (userEscuadraId == 11) {
        Escuadras general = Escuadras(escIdEscuadra: 11, escNombre: "Generales");
        squads.add(general);
        escuadras = squads;
      } else {
        escuadras =
            squads.where((e) => e.escIdEscuadra == userEscuadraId).toList();
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
        await EventController.getEventsByFilters(userEscuadraId, formattedDate, 0);

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

    try{
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      int eventId = selectedEvent?.eveId ?? 0;
      int userEscuadraId =
          selectedEscuadra?.escIdEscuadra ?? authProvider.user!.escuadraId;

      asistencias = await AttendanceController.getAsistencia(
          userEscuadraId, formattedDate, eventId, authProvider.user!.token);

      setState(() => _isLoading = false);
    } catch(e){
      setState(() => _isLoading = false);

      // Verificamos si el error es por el token de 1 minuto (401)
      if (e.toString().contains("UNAUTHORIZED")) {
        //Limpiamos el estado del Provider (opcional pero recomendado)
        Provider.of<AuthProvider>(context, listen: false).logout();

        // 2. Mostramos el mensaje al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text("Su sesión ha expirado. Por favor, ingrese de nuevo."),
            backgroundColor: Colors.redAccent,
          ),
        );

        // 3. Navegamos al login eliminando todo el historial de pantallas
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("Error cargando asistencia $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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

  Future<void> attendanceExportXlsx(
      BuildContext context, List<Asistencia> attendance) async {
    bool success = false;
    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel["Asistencias"];
      excel.delete('Sheet1');

      var headerStyle = CellStyle(
        bold: true,
      );
      sheet.cell(CellIndex.indexByString("A1")).cellStyle = headerStyle;

      // agregamos los encabezados
      sheet.appendRow([
        TextCellValue('Nombres'),
        TextCellValue('Apellidos'),
        TextCellValue('Fecha'),
        TextCellValue('Asistencia'),
        TextCellValue('Comentario'),
      ]);

      // filas
      for (var data in attendance) {
        sheet.appendRow([
          TextCellValue(data.intNombres),
          TextCellValue(data.intApellidos),
          TextCellValue(data.asiFechaAsistencia ?? ''),
          TextCellValue(data.asistencia == 1 ? 'Si' : 'No'),
          TextCellValue(data.asiComentario ?? ''),
        ]);
      }

      final fileBytes = excel.save();

      if (fileBytes != null) {
        final uint8List = Uint8List.fromList(fileBytes);

        await FileSaver.instance.saveAs(
          name: 'Asistencias_${DateTime.now().millisecondsSinceEpoch}',
          bytes: uint8List,
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
        success = true;
      }
    } catch (e) {
      success = false;
    }

    CustomSnackBar.show(
      context,
      success: success,
      message: success
          ? "Archivo descargado correctamente en Descargas."
          : "Error al generar el archivo.",
    );
  }

  Future<void> _showExitDialog(
      BuildContext context, Asistencia asistencia) async {
    final TextEditingController _commentController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => GenericDialog(
        title: 'Confirmación de salida',
        confirmColor: Colors.black,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar salida para:'),
            Text('${asistencia.intNombres} ${asistencia.intApellidos}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _commentController,
              label: 'Comentario...',
              icon: Icons.comment,
              isPassword: false,
              focusLabelColor: Colors.indigo,
            ),
          ],
        ),
        onConfirm: () async {
          bool success =
              await AttendanceController.registerExtraordinaryDeparture(
            eventId: selectedEvent!.eveId,
            exitComment: _commentController.text,
            memberId: asistencia.intIdIntegrante,
            username: authProvider.user!.username,
          );

          if (success) {
            CustomSnackBar.show(context,
                success: true, message: "Salida registrada.");
            _loadAttendance();
          }
          return success;
        },
      ),
    );
  }

  Future<void> _showJustifyDialog(
      BuildContext context, Asistencia asistencia) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return GenericDialog(
          title: 'Motivo de Salida',
          // NO enviamos onConfirm para que solo aparezca el botón de cerrar
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  asistencia.asiComentarioSalida ??
                      'Sin descripción disponible',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: const CustomAppBar(title: 'Asistencia'),
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
                                      style:
                                          const TextStyle(color: Colors.white),
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
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ),
                    SizedBox(
                      width: size.width,
                      child: Text(
                          'Faltantes: ${asistencias.where((a) => a.asistencia == 0).length}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1D6F42),
                            Color(0xFF2E8B57),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            attendanceExportXlsx(context, asistencias);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sim_card_download,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Excel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    attendanceTable(context, asistencias, _showExitDialog,
                        _showJustifyDialog),
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

Widget attendanceTable(
    BuildContext context,
    List<Asistencia> attendance,
    Function(BuildContext, Asistencia) onExitPressed,
    Function(BuildContext, Asistencia) onJustifyPressed) {
  return SingleChildScrollView(
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
              "Fecha entrada",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Fecha salida",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Acciones",
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
                  color: asistencia.asistencia == 1 ? Colors.green : Colors.red,
                ),
              ),
            ),
            DataCell(Text(asistencia.intNombres)),
            DataCell(Text(asistencia.intApellidos)),
            DataCell(Text(
              asistencia.asiFechaAsistencia != null
                  ? DateFormat('dd-MM-yyyy HH:mm:ss')
                      .format(DateTime.parse(asistencia.asiFechaAsistencia!))
                  : "--/--/----",
            )),
            DataCell(Text(
              asistencia.asiFechaSalida != null
                  ? DateFormat('dd-MM-yyyy HH:mm:ss')
                      .format(DateTime.parse(asistencia.asiFechaSalida!))
                  : "--/--/----",
            )),
            DataCell(Row(
              children: <Widget>[
                // if (Utils.isToday(asistencia.asiFechaSalida))
                //   asistencia.asiFechaSalida == null
                //       ? IconButton(
                //           onPressed: () => onExitPressed(context, asistencia),
                //           icon: const Icon(
                //             Icons.exit_to_app,
                //             color: Colors.indigo,
                //           ),
                //         )
                //       : IconButton(
                //           onPressed: () =>
                //               onJustifyPressed(context, asistencia),
                //           icon: const Icon(
                //             Icons.mark_chat_unread,
                //             color: Colors.teal,
                //           ),
                //         )
                // else
                //   const SizedBox(
                //       width: 48,
                //       child: Icon(Icons.history, color: Colors.grey, size: 20)),
                if (asistencia.asiFechaAsistencia != null)
                  asistencia.asiFechaSalida == null
                      ? IconButton(
                    onPressed: () => onExitPressed(context, asistencia),
                    icon: const Icon(
                      Icons.exit_to_app,
                      color: Colors.indigo,
                    ),
                  )
                      : IconButton(
                    onPressed: () =>
                        onJustifyPressed(context, asistencia),
                    icon: const Icon(
                      Icons.mark_chat_unread,
                      color: Colors.teal,
                    ),
                  )
                else
                  const SizedBox(
                      width: 48,
                      child: Icon(Icons.history, color: Colors.grey, size: 20)),
              ],
            ))
          ]);
        }).toList(),
      ),
    ),
  );
}
