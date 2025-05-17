import 'dart:convert';
import 'package:asistencias_egc/models/event.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:http/http.dart' as http;

class EventController {
  static Future<bool> createEvent({
    required String title,
    required String description,
    required String userCreate,
    required String eventDate,
    required String commandersEntry,
    required String membersEntry,
    required int onlyCommanders,
    required List<int> squads,
    required int generalBand,
  }) async {
    String apiUrl = Environments.apiUrl;
    final Uri url =
        Uri.parse('$apiUrl/Event/create_event'); // Endpoint del servidor

    // Estructura del JSON a enviar
    Map<String, dynamic> body = {
      "title": title,
      "description": description,
      "userCreate": userCreate,
      "eventDate": eventDate,
      "commandersEntry": commandersEntry,
      "membersEntry": membersEntry,
      "onlyCommanders": onlyCommanders,
      "squads": squads,
      "generalBand": generalBand
    };

    try {
      print('fecha enviada eventDate == $eventDate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          print(' Evento creado exitosamente: ${data['message']}');
          return true;
        } else {
          throw Exception(
              "Error en la respuesta del servidor: ${data['message']}");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  static Future<List<Event>> getEvents(int idEscuadra) async {
    String apiUrl = Environments.apiUrl;
    final Uri url =
        Uri.parse('$apiUrl/Event/get_events?idEscuadra=$idEscuadra');

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          List<Event> events =
              (data['list'] as List).map((e) => Event.fromJson(e)).toList();
          return events;
        } else {
          throw Exception(
              "Error en la respuesta del servidor: ${data['message']}");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  static Future<bool> deleteEvent({required int idEvent}) async {
    String apiUrl = Environments.apiUrl;
    final Uri url = Uri.parse(
        '$apiUrl/Event/delete_event?idEvent=$idEvent'); // Endpoint del servidor

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return true;
        } else {
          throw Exception("Error en la respuesta del servidor: ${data['message']}");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  static Future<List<Event>> getEventsBySquad(int idEscuadra) async {
    String apiUrl = Environments.apiUrl;
    final Uri url =
    Uri.parse('$apiUrl/Event/get_events_by_squad?idEscuadra=$idEscuadra');

    try {
      final response =
      await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          List<Event> events =
          (data['list'] as List).map((e) => Event.fromJson(e)).toList();
          return events;
        } else {
          throw Exception(
              "Error en la respuesta del servidor: ${data['message']}");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  static Future<List<Event>> getEventsByFilters(int idEscuadra, String date) async {
    String apiUrl = Environments.apiUrl;
    final Uri url =
    Uri.parse('$apiUrl/Event/get_events_by_filters?idEscuadra=$idEscuadra&date=$date');

    try {
      final response =
      await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          List<Event> events =
          (data['list'] as List).map((e) => Event.fromJson(e)).toList();
          return events;
        } else {
          throw Exception(
              "Error en la respuesta del servidor: ${data['message']}");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }


}
