import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/event_controller.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/FadeInUp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScannerEvent extends StatefulWidget {
  const ScannerEvent({super.key});

  @override
  State<ScannerEvent> createState() => _ScannerEventState();
}

class _ScannerEventState extends State<ScannerEvent> {
  bool _isLoading = false;
  List<Event> list = [];

  Future<void> _getEvents() async {
    setState(() {
      _isLoading = true;
    });

    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId = authProvider.user!.escuadraId; // Obtener el escuadraId
    List<Event> dataList =
        await EventController.getEventsBySquad(userEscuadraId);
    setState(() {
      _isLoading = false;
      list = dataList;
    });
  }

  @override
  void initState() {
    super.initState();
    _getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PopScope(
          canPop: true,
          child: Scaffold(
            body: Center(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: const Duration(seconds: 0),
                  duration: const Duration(seconds: 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black, // Fondo negro
                      borderRadius:
                          BorderRadius.circular(10), // Bordes redondeados
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, 'scanner',
                          arguments: list[index].eveId),
                      child: ListTile(
                        title: Text(
                          list[index].eveTitulo,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        leading: const Icon(Icons.event, color: Colors.white),
                        subtitle: Text(
                          list[index].eveDescripcion,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.navigate_next,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }
}
