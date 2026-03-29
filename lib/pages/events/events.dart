import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isLoading = false;
  Map<DateTime, List<Event>> eventsMap = {};
  DateTime? _lastTappedDay;
  DateTime? _lastTapTime;
  int userEscuadraId = 0;

  @override
  void initState() {
    super.initState();
    _getEvents();
  }

  Future<void> _getEvents() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      userEscuadraId = authProvider.user!.escuadraId;
    });
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

  Future<void> _handleEndEvent(int eventId) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    String username = authProvider.user!.username;

    setState(() => _isLoading = true);

    bool success = await EventController.endEvent(
      eventId: eventId,
      username: username,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context); // Cierra el modal de lista de eventos
      _getEvents(); // Refresca el calendario
    }

    CustomSnackBar.show(
      context,
      success: success,
      message: success
          ? "Evento finalizado exitosamente."
          : "Error al finalizar el evento",
    ); // [cite: 68]
  }

  void _confirmEndEvent(int eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar acción"),
          content: const Text("¿Está seguro que desea finalizar el evento?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Solo cierra el diálogo
              child: Text("No", style: TextStyle(color: Colors.red[900])),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                _handleEndEvent(eventId); // Ejecuta la lógica
              },
              child: const Text("Si", style: TextStyle(color: Colors.indigo)),
            ),
          ],
        );
      },
    );
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
            appBar: const CustomAppBar(title: 'Eventos'),
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
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
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
            floatingActionButton: userEscuadraId == 11
                ? FloatingActionButton(
                    onPressed: _navigateToEventForm,
                    backgroundColor: Colors.black,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, size: 30, color: Colors.white),
                  )
                : null,
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
      isScrollControlled: true,
      // Permite que el modal crezca más allá del 50% si es necesario
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          // Ideal para listas en modales
          initialChildSize: 0.6,
          // Altura inicial (60%)
          minChildSize: 0.4,
          // Altura mínima
          maxChildSize: 0.9,
          // Altura máxima al deslizar
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Tirador visual para el modal
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    "Eventos del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // USAMOS EXPANDED PARA EVITAR EL OVERFLOW
                  Expanded(
                    child: events.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            // Conecta el scroll del modal
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return _buildEventItem(
                                  event); // He extraído esto para limpiar el código
                            },
                          )
                        : const Center(
                            child: Text("No hay eventos para esta fecha",
                                style: TextStyle(fontSize: 16)),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Widget auxiliar para mantener el código limpio y evitar errores de anidación
  Widget _buildEventItem(Event event) {
    return Card(
      // Agregamos un Card para separar visualmente los eventos
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            onTap: () =>
                Navigator.pushNamed(context, 'event_form', arguments: event),
            title: Text(event.eveTitulo,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.event, color: Colors.indigo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.eveDescripcion),
                Text('Cmte: ${event.eveHoraEntradaComandantes}',
                    style: const TextStyle(fontSize: 12)),
                Text('Int: ${event.eveHoraEntradaIntegrantes}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          if (event.eveActivo == 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(Icons.check_circle, "Finalizar", Colors.indigo,
                      () => _confirmEndEvent(event.eveId)),
                  _actionButton(
                      Icons.delete,
                      "Eliminar",
                      Colors.red,
                      () => _logicEliminar(
                          event)
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _logicEliminar(Event event) async {
    // 1. Preguntar al usuario para evitar errores
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("¿Eliminar evento?"),
            content: Text("¿Estás seguro de eliminar '${event.eveTitulo}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text("Eliminar", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      // 2. Llamada al controlador
      bool success = await EventController.deleteEvent(idEvent: event.eveId);

      if (success) {
        // 3. Cerramos el ModalBottomSheet que está abierto
        Navigator.pop(context);

        // 4. Refrescamos la lista general (debe tener un setState interno)
        _getEvents();

        // 5. Feedback visual
        CustomSnackBar.show(
          context,
          success: true,
          message: "Evento eliminado correctamente.",
        );
      } else {
        CustomSnackBar.show(
          context,
          success: false,
          message: "No se pudo eliminar el evento.",
        );
      }
    }
  }

/*
  void _showEventListModal(DateTime selectedDate) {
    List<Event> events = eventsMap[selectedDate] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height *
                  0.5, // Ajustar altura al 60% de la pantalla
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Eventos del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  events.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, 'event_form',
                                    arguments: events[index]);
                              },
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      events[index].eveTitulo,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    leading: const Icon(Icons.event,
                                        color: Colors.black),
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
                                  ),
                                  events[index].eveActivo == 1
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.indigo),
                                                  onPressed: () => _confirmEndEvent(
                                                      events[index].eveId),
                                                ),
                                                const Text("Finalizar")
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () async {
                                                    bool success =
                                                        await EventController
                                                            .deleteEvent(
                                                                idEvent:
                                                                    events[index]
                                                                        .eveId);

                                                    if (success) {
                                                      Navigator.pop(
                                                          context); // Cerrar el modal
                                                      _getEvents();
                                                      CustomSnackBar.show(
                                                        context,
                                                        success: success,
                                                        message: success
                                                            ? "Evento eliminado exitosamente."
                                                            : " ",
                                                      );
                                                    } else {
                                                      CustomSnackBar.show(
                                                        context,
                                                        success: success,
                                                        message: success
                                                            ? "Error al eliminar el evento"
                                                            : "Error al eliminar el evento",
                                                      );
                                                    }
                                                  }, // Sin acción por ahora
                                                ),
                                                const Text("Eliminar")
                                              ],
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ],
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
            ),
          ],
        );
      },
    );
  }
*/
}
