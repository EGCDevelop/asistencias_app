import 'dart:convert';

import 'package:asistencias_egc/models/Career.dart';
import 'package:asistencias_egc/models/Establishment.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/utils/api/Degrees.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:asistencias_egc/utils/api/Position.dart';
import 'package:http/http.dart' as http;

class GeneralMethodsControllers {
  static Future<List<Escuadras>> GetSquads() async {
    String apiUrl = Environments.apiUrl;

    final Uri url = Uri.parse('$apiUrl/GeneralMethods/get_squads');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => Escuadras.fromJson(item))
              .toList();
        } else {
          throw Exception("La respuesta no es válida");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  static Future<List<Establishment>> getEstablishment() async {
    String apiUrl = Environments.apiUrl;

    final Uri url = Uri.parse('$apiUrl/GeneralMethods/get_establishment');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => Establishment.fromJson(item))
              .toList();
        } else {
          throw Exception("La respuesta no es válida");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  static Future<List<Degrees>> getDegrees() async {
    String apiUrl = Environments.apiUrl;

    final Uri url = Uri.parse('$apiUrl/GeneralMethods/get_degrees');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => Degrees.fromJson(item))
              .toList();
        } else {
          throw Exception("La respuesta no es válida");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  static Future<List<Position>> getPosition() async {
    String apiUrl = Environments.apiUrl;

    final Uri url = Uri.parse('$apiUrl/GeneralMethods/get_position');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => Position.fromJson(item))
              .toList();
        } else {
          throw Exception("La respuesta no es válida");
        }
      } else {
        throw Exception("Error en la petición: ${response.statusCode}");
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  static Future<List<Career>> getCareer() async {
    String apiUrl = Environments.apiUrl;

    final Uri url = Uri.parse('$apiUrl/GeneralMethods/get_career');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true) {
          return (data['list'] as List)
              .map((item) => Career.fromJson(item))
              .toList();
        } else {
          throw Exception("La respuesta no es válida");
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
