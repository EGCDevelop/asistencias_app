import 'dart:convert';
import 'package:asistencias_egc/models/integrantes.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class MembersController {
  static Future<List<Integrantes>> getMemberLike({
    required String like,
    required int squadId,
    required int schoolId,
    required int isNew,
    required int memberState,
  }) async {
    String apiUrl = Environments.apiUrl;
    final Uri url = Uri.parse(
        '$apiUrl/Member/get_member_like?like=$like&squadId=$squadId&schoolId=$schoolId&isNew=$isNew&memberState=$memberState');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => Integrantes.fromJson(item))
              .toList();
        } else {
          throw Exception("La respuesta no es válida");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      return [];
    }
  }

  static Future<bool> updateMember(
      {required int memberId,
      required String firstName,
      required String lastName,
      required String cellPhone,
      required int squadId,
      required int positionId,
      required int isActive,
      required int isAncient,
      required int establecimientoId,
      required String anotherEstablishment,
      required int courseId,
      required String courseName,
      required int degreeId,
      required String section,
      required String fatherName,
      required String fatherCell}) async {
    String apiUrl = Environments.apiUrl;
    final Uri url = Uri.parse('$apiUrl/Member/update_member');

    // JSON a enviar
    Map<String, dynamic> body = {
      "memberId": memberId,
      "firstName": firstName,
      "lastName": lastName,
      "cellPhone": cellPhone,
      "squadId": squadId,
      "positionId": positionId,
      "isActive": isActive,
      "isAncient": isAncient,
      "establecimientoId": establecimientoId,
      "anotherEstablishment": anotherEstablishment,
      "courseId": courseId,
      "courseName": courseName,
      "degreeId": degreeId,
      "section": section,
      "fatherName": fatherName,
      "fatherCell": fatherCell
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return true;
        } else {
          throw Exception(
              "Error en la respuesta del servidor: ${data['message']}");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      return false;
    }
  }
}
