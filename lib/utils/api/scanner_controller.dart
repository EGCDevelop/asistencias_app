import 'dart:convert';

import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:http/http.dart' as http;


class ScannerController {
  static Future<Map<String, dynamic>> registerAttendance({
    required String id,
    required String escuadra,
    required String puesto,
    required String token,
    required String eventId,
    required String idRegistro,
  }) async {
    String apiUrl = Environments.apiUrl;

    final Uri url = Uri.parse('$apiUrl/Asistencia/register_attendance');

    final Map<String, dynamic> body = {
      'id': id,
      'escuadra': escuadra,
      'puesto': puesto,
      'eventId': eventId,
      'idRegistro' : idRegistro
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok']) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error desconocido'};
      }
    } catch(e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }


  }
}