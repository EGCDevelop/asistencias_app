class Asistencia {
  final int intIdIntegrante;
  final String intNombres;
  final String intApellidos;
  final int? asiIdAsistencia;
  final String? asiFechaAsistencia;
  final int asistencia;

  Asistencia({
    required this.intIdIntegrante,
    required this.intNombres,
    required this.intApellidos,
    this.asiIdAsistencia,
    this.asiFechaAsistencia,
    required this.asistencia,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      intIdIntegrante: json['intIdIntegrante'],
      intNombres: json['intNombres'],
      intApellidos: json['intApellidos'],
      asiIdAsistencia: json['asiIdAsistencia'],
      asiFechaAsistencia: json['asiFechaAsistencia'],
      asistencia: json['asistencia'],
    );
  }
}
