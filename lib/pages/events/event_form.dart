import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/widgets/CustomTextField.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/CustomDatePicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  int? eventId;
  List<Escuadras> escuadras = [];
  List<Escuadras> selectedSquads = [];
  List<Escuadras> originalSquads = [];
  Escuadras? selectedEscuadra;
  bool _isLoading = false;

  // Controladores de texto para los campos
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool _onlyCommanders = false;
  bool _generalBand = true;
  DateTime? selectedDate;

  // Controlador para mostrar la hora en un TextField
  final TextEditingController _timeControllerComanders =
      TextEditingController();
  final TextEditingController _timeControllerMembers = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSquads();
    //_loadAquads();
  }

  Future<void> _loadSquads() async {
    setState(() {
      _isLoading = true;
    });
    List<Escuadras> squads = await GeneralMethodsControllers.GetSquads();

    setState(() {
      escuadras = squads;
      originalSquads = List.from(squads);
      _isLoading = false;
    });
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.black,
              helpTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              hourMinuteColor: Colors.white,
              hourMinuteTextColor: Colors.black,
              dialHandColor: Colors.black,
              dialBackgroundColor: Colors.white,
              entryModeIconColor: Colors.white,
              dayPeriodColor: Colors.white,
              dayPeriodTextColor: Colors.black,
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                    Colors.white), // Texto de "OK" en blanco
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                    Colors.white), // Texto de "Cancel" en blanco
              ),
            ),
            colorSchemeSeed: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      //_timeController.text = picked.format(context); // Actualiza el campo
      controller.text = picked.format(context);
    }
  }

  Future<void> _loadSelectedSquads() async {
    if (eventId != null) {
      setState(() {
        _isLoading = true;
      });

      final results =
          await Future.wait([EventController.getSquadByEventId(eventId!)]);

      setState(() {
        selectedSquads = results[0];

        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args is Event) {
      // EDITAR EVENTO
      eventId = args.eveId;
      selectedDate = DateTime.parse(args.eveFechaEvento);
      _titleController.text = args.eveTitulo; // Asignar título al campo
      _descriptionController.text = args.eveDescripcion;
      _onlyCommanders = args.eveSoloComandantes == 1 ? true : false;
      _timeControllerComanders.text = args.eveHoraEntradaComandantes;
      _timeControllerMembers.text = args.eveHoraEntradaIntegrantes!;
      _generalBand = args.eveBandaGeneral == 1;

      _loadSelectedSquads();
    } else if (args is DateTime) {
      selectedDate = args;
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      var authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<int> idList = [];
      String username = authProvider.user!.username;

      // banda general
      if (_generalBand) {
        for (int i = 1; i < 12; i++) {
          idList.add(i);
        }
      } else {
        for (int i = 0; i < selectedSquads.length; i++) {
          idList.add(selectedSquads[i].escIdEscuadra);
        }
      }

      bool success = await EventController.createEvent(
          title: _titleController.text,
          description: _descriptionController.text,
          userCreate: username,
          eventDate:
              "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
          commandersEntry: _timeControllerComanders.text,
          membersEntry: _timeControllerMembers.text,
          onlyCommanders: _onlyCommanders ? 1 : 0,
          squads: idList,
          generalBand: _generalBand ? 1 : 0);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Evento creado exitosamente"
              : "Error al crear el evento"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      // Si la respuesta es correcta, regresar a la pantalla anterior
      if (success) {
        Future.delayed(const Duration(milliseconds: 100), () {
          // Espera breve para ver el mensaje
          Navigator.pop(context, true); // Regresa a la pantalla anterior
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopScope(
          canPop: true,
          child: Scaffold(
              appBar: AppBar(title: const Text("Formulario de Evento")),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 20,
                        ),
                        _titles('Datos del evento'),
                        CustomDatePicker(
                          selectedDate: selectedDate!,
                          onTap: () => {},
                          validator: (value) => selectedDate == null
                              ? "Selecciona una fecha"
                              : null,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                          controller: _titleController,
                          label: 'Título',
                          icon: Icons.title,
                          isPassword: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          icon: Icons.title,
                          isPassword: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un descripción';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        _titles('Hora del evento'),
                        Row(
                          children: [
                            Checkbox(
                              value: _onlyCommanders,
                              activeColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  _onlyCommanders = value!;
                                });
                              },
                            ),
                            const Text("Solo comandantes"),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _timeControllerComanders,
                          cursorColor: Colors.black,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Entrada comandantes',
                            prefixIcon: const Icon(Icons.watch_later),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          onTap: () =>
                              _selectTime(context, _timeControllerComanders),
                          // Abre el selector de hora
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, selecciona una hora';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _timeControllerMembers,
                          cursorColor: Colors.black,
                          readOnly: true,
                          enabled: !_onlyCommanders,
                          decoration: InputDecoration(
                            labelText: 'Entrada integrantes',
                            prefixIcon: const Icon(
                              Icons.watch_later_outlined,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          onTap: () =>
                              _selectTime(context, _timeControllerMembers),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        _titles('Escuadras'),
                        Row(
                          children: [
                            Checkbox(
                              value: _generalBand,
                              activeColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  _generalBand = value!;
                                  if (_generalBand) {
                                    selectedSquads.clear(); // Borra los tags
                                    escuadras = List.from(originalSquads);
                                  }
                                });
                              },
                            ),
                            const Text("Banda general"),
                          ],
                        ),
                        _generalBand
                            ? Container()
                            : eventId == null
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: DropdownButton<Escuadras>(
                                      value: selectedEscuadra,
                                      dropdownColor: Colors.black,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      underline: Container(),
                                      onChanged: (Escuadras? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedSquads.add(newValue);
                                            escuadras.remove(newValue);
                                            selectedEscuadra = null;
                                          });
                                        }
                                      },
                                      items: escuadras.map((escuadra) {
                                        return DropdownMenuItem<Escuadras>(
                                          value: escuadra,
                                          child: Text(
                                            escuadra.escNombre,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : Container(),
                        const SizedBox(
                          height: 10,
                        ),
                        Wrap(
                          spacing: 8,
                          children: selectedSquads.map((escuadra) {
                            return Chip(
                              label: Text(
                                escuadra.escNombre,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black,
                              //
                              side: const BorderSide(
                                  color: Colors.black, width: 1),
                              shape: const StadiumBorder(),
                              onDeleted: () {
                                setState(() {
                                  escuadras
                                      .add(escuadra); // Regresar al Dropdown
                                  selectedSquads.remove(
                                      escuadra); // Eliminar de la lista de tags
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        eventId == null
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: _handleLogin,
                                  child: const Text(
                                    "GUARDAR",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }

  Widget _titles(String text) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      width: double.infinity,
      child: Text(text),
    );
  }
}
