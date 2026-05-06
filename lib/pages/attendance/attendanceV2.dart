import 'dart:typed_data';
import 'package:asistencias_egc/models/Asistencia.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/attendance_controller.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/widgets/CustomTextField.dart';
import 'package:asistencias_egc/widgets/GenericDialog.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/CustomSnackBar.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AttendanceV2 extends StatefulWidget {
  const AttendanceV2({super.key});

  @override
  State<AttendanceV2> createState() => _AttendanceV2State();
}

class _AttendanceV2State extends State<AttendanceV2> {
  List<Escuadras> escuadras = [];
  List<Asistencia> asistencias = [];
  Escuadras? selectedEscuadra;
  List<Event> events = [];
  Event? selectedEvent;
  bool _isLoading = false;
  DateTime selectedDate = DateTime.now();
  Event? argumentEvent;
  bool isInitialized = false;
  int? targetEventId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments;

      if (args is Event) {
        argumentEvent = args;
        targetEventId = args.eveId;
        selectedDate = DateTime.parse(args.eveFechaEvento);
      }

      _loadSquads();

      setState(() {
        isInitialized = true;
      });
    }
  }

  Future<void> _loadSquads() async {
    setState(() {
      _isLoading = true;
    });

    List<Escuadras> squads = await GeneralMethodsControllers.GetSquads();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int? userEscuadraId = authProvider.user!.escuadraId;

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
      } else if (userEscuadraId == 4) {
        escuadras = squads
            .where((e) =>
                e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 5)
            .toList();
      } else if (userEscuadraId == 5) {
        escuadras = squads
            .where((e) =>
                e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 4)
            .toList();
      } else if (userEscuadraId == 11) {
        Escuadras general =
            Escuadras(escIdEscuadra: 11, escNombre: "Generales");
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
      _getEvents();
    }
  }

  Future<void> _getEvents() async {
    setState(() => _isLoading = true);

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId =
        selectedEscuadra?.escIdEscuadra ?? authProvider.user!.escuadraId;

    List<Event> dataList = await EventController.getEventsByFilters(
        userEscuadraId, formattedDate, 0);

    setState(() {
      events = dataList;

      if (events.isNotEmpty) {
        if (targetEventId != null) {
          selectedEvent =
              events.where((e) => e.eveId == targetEventId).firstOrNull;
        }

        selectedEvent ??= (events.length > 1) ? events[1] : events.first;
      } else {
        selectedEvent = null;
        asistencias.clear();
      }

      _isLoading = false;
    });

    if (selectedEvent != null) {
      _loadAttendance();
    } else {
      setState(() => asistencias.clear());
    }
  }

  Future<void> _loadAttendance() async {
    if (selectedEscuadra == null || events.isEmpty) {
      setState(() {
        asistencias.clear();
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      int eventId = selectedEvent?.eveId ?? 0;
      int userEscuadraId =
          selectedEscuadra?.escIdEscuadra ?? authProvider.user!.escuadraId;

      asistencias = await AttendanceController.getAsistencia(
          userEscuadraId, formattedDate, eventId, authProvider.user!.token);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);

      if (e.toString().contains("UNAUTHORIZED")) {
        Provider.of<AuthProvider>(context, listen: false).logout();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Su sesión ha expirado. Por favor, ingrese de nuevo."),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error cargando asistencia $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
        Uint8List uint8List = Uint8List.fromList(fileBytes);

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
    final TextEditingController commentController = TextEditingController();
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
              controller: commentController,
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
            exitComment: commentController.text,
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

  Future<void> _showRegisterJustification(
      BuildContext context, Asistencia attendance) async {
    final TextEditingController registerJustificationController =
        TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => GenericDialog(
        title: "Ausencia",
        confirmColor: Colors.black,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Registrar justificación de asuencia para:'),
            Text('${attendance.intNombres} ${attendance.intApellidos}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CustomTextField(
              controller: registerJustificationController,
              label: "Justificación",
              icon: Icons.comment,
              isPassword: false,
              focusLabelColor: Colors.indigo,
            ),
          ],
        ),
        onConfirm: () async {
          bool success =
              await AttendanceController.registerJustificationAbsence(
                  username: authProvider.user!.username,
                  eventId: selectedEvent!.eveId,
                  justificationComment: registerJustificationController.text,
                  memberId: attendance.intIdIntegrante,
                  usernameId: authProvider.user!.idIntegrante);

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

  Future<void> _showViewJustification(
      BuildContext context, Asistencia asistencia) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return GenericDialog(
          title: 'Detalle de Justificación',
          // Solo botón de cerrar
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Registrado por: ${asistencia.asiUsuarioRegistroJustificacion ?? "N/A"}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              const Text('Motivo:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  //border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  asistencia.asiJustificacionFalta ?? 'Sin descripción',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // 2. Si el usuario aún es nulo, mostramos la pantalla de carga
    if (user == null) {
      return Scaffold(
        body: Center(child: LoadingAnimation()),
      );
    }

    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text(
                'Asistencia',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.black,
              onRefresh: _loadAttendance,
              displacement: 30,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                      selectedEvent != null
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${selectedEvent?.eveTitulo}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Text('${selectedEvent?.eveDescripcion}',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 14)),
                                  Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(selectedDate),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.5,
                        children: <Widget>[
                          _buildSummaryCard(
                            label: 'Total',
                            value: '${asistencias.length}',
                            color: Colors.blue,
                            icon: Icons.people,
                          ),
                          _buildSummaryCard(
                            label: 'Asistencias',
                            value:
                                '${asistencias.where((a) => a.asistencia == 1 && a.asiTieneJustificacion != 2).length}',
                            color: Colors.green,
                            icon: Icons.check_circle_outline,
                          ),
                          _buildSummaryCard(
                            label: 'Permisos',
                            value:
                                '${asistencias.where((a) => a.asiTieneJustificacion == 2).length}',
                            color: Colors.orange,
                            icon: Icons.info_outline,
                          ),
                          _buildSummaryCard(
                            label: 'Faltantes',
                            value:
                                '${asistencias.where((a) => a.asistencia == 0).length}',
                            color: Colors.red,
                            icon: Icons.highlight_off,
                          ),
                        ],
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
                      attendanceTable(
                          context,
                          asistencias,
                          _showExitDialog,
                          _showJustifyDialog,
                          _showRegisterJustification,
                          _showViewJustification),
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

  Widget attendanceTable(
      BuildContext context,
      List<Asistencia> attendance,
      Function(BuildContext, Asistencia) onExitPressed,
      Function(BuildContext, Asistencia) onJustifyPressed,
      Function(BuildContext, Asistencia) onRegisterJustification,
      Function(BuildContext, Asistencia) showViewJustification) {
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
                    asistencia.asiTieneJustificacion == 2
                        ? Icons
                            .info_outline // Icono de información para permisos
                        : asistencia.asistencia == 1
                            ? Icons.check_circle
                            : Icons.cancel,
                    color: asistencia.asiTieneJustificacion == 2
                        ? Colors.orange
                        : (asistencia.asistencia == 1
                            ? Colors.green
                            : Colors.red),
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
                        child:
                            Icon(Icons.history, color: Colors.grey, size: 20)),
                  if (asistencia.asiTieneJustificacion == 2)
                    IconButton(
                      icon: const Icon(
                        Icons.edit_note,
                        color: Colors.orange,
                      ),
                      onPressed: () =>
                          showViewJustification(context, asistencia),
                    )
                  else
                    IconButton(
                      onPressed: () =>
                          onRegisterJustification(context, asistencia),
                      icon: const Icon(
                        Icons.gas_meter,
                        color: Colors.indigoAccent,
                      ),
                    )
                ],
              ))
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.1), // Fondo leve del color correspondiente
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
