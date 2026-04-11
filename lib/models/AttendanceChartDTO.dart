class AttendanceChartDTO {
  final int escIdEscuadra;
  final String escNombre;
  final int totalIntegrantes;
  final int asistencias;
  final int permisos;
  final int faltan;
  final int eventoId;
  final String nombreEvento;

  AttendanceChartDTO({
    required this.escIdEscuadra,
    required this.escNombre,
    required this.totalIntegrantes,
    required this.asistencias,
    required this.permisos,
    required this.faltan,
    required this.eventoId,
    required this.nombreEvento,
  });

  factory AttendanceChartDTO.fromJson(Map<String, dynamic> json) {
    return AttendanceChartDTO(
      escIdEscuadra: json['escIdEscuadra'],
      escNombre: json['escNombre'],
      totalIntegrantes: json['totalIntegrantes'],
      asistencias: json['asistencias'],
      permisos: json["permisos"],
      faltan: json['faltan'],
      eventoId: json['eventoId'],
      nombreEvento: json['nombreEvento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'escIdEscuadra': escIdEscuadra,
      'escNombre': escNombre,
      'totalIntegrantes': totalIntegrantes,
      'asistencias': asistencias,
      'permisos': permisos,
      'faltan': faltan,
      'eventoId': eventoId,
      'nombreEvento': nombreEvento,
    };
  }
}