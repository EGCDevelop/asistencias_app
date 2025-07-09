class AttendanceChartDTO {
  final int escIdEscuadra;
  final String escNombre;
  final int totalIntegrantes;
  final int asistencias;
  final int faltan;
  final int eventoId;
  final String nombreEvento;

  AttendanceChartDTO({
    required this.escIdEscuadra,
    required this.escNombre,
    required this.totalIntegrantes,
    required this.asistencias,
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
      'faltan': faltan,
      'eventoId': eventoId,
      'nombreEvento': nombreEvento,
    };
  }
}