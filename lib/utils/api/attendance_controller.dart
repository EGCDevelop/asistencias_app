import 'dart:convert';

import 'package:asistencias_egc/models/Asistencia.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:http/http.dart' as http;

class AttendanceController {
  static Future<List<Asistencia>> getAsistencia(
      int idEscuadra, String date, int eventId, String token) async {
    String apiUrl = Environments.apiUrl;
    final Uri url = Uri.parse(
        '$apiUrl/Asistencia/get_asistencia?idEscuadra=$idEscuadra&date=$date&eventId=$eventId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
      }

      if (response.statusCode == 401) {
        throw Exception("UNAUTHORIZED");
      }

      throw Exception("Error en la petición: ${response.statusCode}");
    } catch (e) {
      print('Error detectado: $e');
      rethrow;
    }
  }

  static Future<bool> registerExtraordinaryDeparture(
      {required int eventId,
      required String exitComment,
      required int memberId,
      required String username}) async {
    String apiUrl = Environments.apiUrl;
    final Uri url =
        Uri.parse('$apiUrl/Asistencia/register_extraordinary_departure');

    try {
      final Map<String, dynamic> bodyData = {
        'eventId': eventId,
        'exitComment': exitComment,
        'memberId': memberId,
        'username': username
      };

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ok'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMatrizAsistencia(
      {required int squadId,
      required int memberType,
      required int position,
      required DateTime startDate}) async {
    String apiUrl = Environments.apiUrl;

    String formattedDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";

    final Uri url = Uri.parse('$apiUrl/Asistencia/get_matriz_asistencia'
        '?idEscuadra=$squadId'
        '&tipoIntegrante=$memberType'
        '&filtroPuesto=$position'
        '&fechaInicio=$formattedDate');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          return List<Map<String, dynamic>>.from(data['list']);
        } else {
          throw Exception("Error en la respuesta del servidor");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }
}
