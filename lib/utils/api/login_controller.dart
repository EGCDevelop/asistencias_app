import 'dart:convert';
import 'package:asistencias_egc/models/login/LoginResponse.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:http/http.dart' as http;


class LoginController {

  static Future<Map<String, dynamic>> login(String username, String password, String version) async {
    String apiUrl = Environments.apiUrl;

    final Uri url = Uri.parse('$apiUrl/Login/login');
    final Map<String, dynamic> body = {
      'username': username,
      'password': password,
      'version': version,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body)
      );

      final data = jsonDecode(response.body);

      if(response.statusCode == 200 && data['ok']) {
        return {'success': true, 'data': LoginResponse.fromJson(data)};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error desconocido'};
      }
    } catch(e){
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}