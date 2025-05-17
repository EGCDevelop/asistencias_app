import 'dart:convert';

import 'package:asistencias_egc/models/Asistencia.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:http/http.dart' as http;

class AttendanceController {
  static Future<List<Asistencia>> getAsistencia(
      int idEscuadra, String date, int eventId) async {
    String apiUrl = Environments.apiUrl;
    final Uri url = Uri.parse(
        '$apiUrl/Asistencia/get_asistencia?idEscuadra=$idEscuadra&date=$date&eventId=$eventId');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => Asistencia.fromJson(item))
              .toList();
        } else {
          throw Exception("Error en la respuesta");
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
