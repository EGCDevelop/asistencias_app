import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/utils/utils.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isLoading = false;
  Map<DateTime, List<Event>> eventsMap = {};
  DateTime? _lastTappedDay;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _getEvents();
  }

  Future<void> _getEvents() async {
    setState(() {
      _isLoading = true;
    });

    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId = authProvider.user!.escuadraId; // Obtener el escuadraId
    List<Event> list = await EventController.getEvents(userEscuadraId);

    eventsMap = {};
    for (var event in list) {
      DateTime eventDate = DateTime.parse(event.eveFechaEvento);
      DateTime normalizedDate = DateTime(
          eventDate.year, eventDate.month, eventDate.day); // Eliminar la hora

      eventsMap.putIfAbsent(normalizedDate, () => []);
      eventsMap[normalizedDate]!.add(event);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _navigateToEventForm() async {
    final result = await Navigator.pushNamed(context, 'event_form',
        arguments: _selectedDay);
    if (result == true) {
      _getEvents(); // Refresca los eventos en el calendario
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight =
        MediaQuery.of(context).size.height; // Obtiene altura de pantalla

    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            appBar: AppBar(title: const Text("Eventos")),
            body: Column(
              children: [
                Expanded(
                  child: TableCalendar(
                    locale: 'en_US',
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 1, 1),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) =>
                        eventsMap[DateTime(day.year, day.month, day.day)] ?? [],
                    rowHeight: screenHeight * 0.135,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: Colors.black, // Color dia actual
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.yellow.shade700, // Color de selección
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 5,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red, // Color del marcador
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${events.length}',
                                // Número de eventos en ese día
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      DateTime now = DateTime.now();
                      DateTime normalizedSelectedDay = DateTime(
                          selectedDay.year, selectedDay.month, selectedDay.day);

                      // Verificar si el usuario hizo doble tap en la misma fecha
                      if (_lastTappedDay == normalizedSelectedDay &&
                          _lastTapTime != null &&
                          now.difference(_lastTapTime!) <
                              const Duration(milliseconds: 300)) {
                        if ((eventsMap[normalizedSelectedDay] ?? [])
                            .isNotEmpty) {
                          _showEventListModal(normalizedSelectedDay);
                        }
                      }

                      _lastTappedDay = normalizedSelectedDay;
                      _lastTapTime = now;

                      setState(() {
                        _selectedDay = selectedDay;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _selectedDay != null
                        ? "${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}"
                        : "Selecciona una fecha",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _navigateToEventForm,
              backgroundColor: Colors.black,
              shape: const CircleBorder(),
              // Esto fuerza la forma completamente circular
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation
                .endFloat, // Posición en la esquina inferior derecha
          ),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }

  void _showEventListModal(DateTime selectedDate) {
    List<Event> events = eventsMap[selectedDate] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.5, // Ajustar altura al 60% de la pantalla
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Eventos del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              events.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'event_form', arguments: events[index]);
                          },
                          child: ListTile(
                            title: Text(
                              events[index].eveTitulo,
                              style: const TextStyle(fontSize: 16),
                            ),
                            leading:
                                const Icon(Icons.event, color: Colors.black),
                            subtitle: Column(
                              children: <Widget>[
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    events[index].eveDescripcion,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    'Cmte : ${events[index].eveHoraEntradaComandantes}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    'Int : ${events[index].eveHoraEntradaIntegrantes}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool success =
                                    await EventController.deleteEvent(
                                        idEvent: events[index].eveId);

                                if (success) {
                                  Navigator.pop(context); // Cerrar el modal
                                  _getEvents();
                                  CustomSnackBar.show(
                                    context,
                                    success: success,
                                    message: success
                                        ? "Evento eliminado exitosamente."
                                        : " ",
                                  );
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //     content:
                                  //         Text("Evento eliminado exitosamente"),
                                  //     backgroundColor: Colors.green,
                                  //   ),
                                  // );
                                } else {
                                  CustomSnackBar.show(
                                    context,
                                    success: success,
                                    message: success
                                        ? "Error al eliminar el evento"
                                        : "Error al eliminar el evento",
                                  );
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //     content:
                                  //         Text("Error al eliminar el evento"),
                                  //     backgroundColor: Colors.red,
                                  //   ),
                                  // );
                                }
                              }, // Sin acción por ahora
                            ),
                          ),
                        );
                      },
                    )
                  : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No hay eventos para esta fecha",
                          style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        );
      },
    );
  }
}
