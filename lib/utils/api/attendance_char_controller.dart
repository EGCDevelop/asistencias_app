import 'dart:convert';

import 'package:asistencias_egc/models/AttendanceChartDTO.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AttendanceCharController {
  static Future<List<AttendanceChartDTO>> getChartData(
    BuildContext context,
    int eventId,
    int escuadra,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String apiUrl = Environments.apiUrl;
    final Uri url = Uri.parse(
        '$apiUrl/Chart/get_data_from_attendance_charet?eventId=$eventId&squadId=$escuadra');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => AttendanceChartDTO.fromJson(item))
              .toList();
        } else {
          throw Exception("Respuesta inválida del servidor");
        }
      } else {
        throw Exception("Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener datos del gráfico: $e");
      return [];
    }
  }
}
