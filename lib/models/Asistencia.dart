class Asistencia {
  final int intIdIntegrante;
  final String intNombres;
  final String intApellidos;
  final int? asiIdAsistencia;
  final String? asiFechaAsistencia;
  final int asistencia;
  final int asieveId;
  final int asiintIdIntegranteRegistro;
  final int asiEsExtraordinaria;
  final String? asiComentario;
  final String? asiFechaRegistroExtraordinaria;

  Asistencia(
      {required this.intIdIntegrante,
      required this.intNombres,
      required this.intApellidos,
      this.asiIdAsistencia,
      this.asiFechaAsistencia,
      required this.asistencia,
      required this.asieveId,
      required this.asiintIdIntegranteRegistro,
      required this.asiEsExtraordinaria,
      this.asiComentario,
      this.asiFechaRegistroExtraordinaria});

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
        intIdIntegrante: json['intIdIntegrante'],
        intNombres: json['intNombres'],
        intApellidos: json['intApellidos'],
        asiIdAsistencia: json['asiIdAsistencia'],
        asiFechaAsistencia: json['asiFechaAsistencia'],
        asistencia: json['asistencia'],
        asieveId: json['asieveId'],
        asiintIdIntegranteRegistro: json['asiintIdIntegranteRegistro'],
        asiEsExtraordinaria: json['asiEsExtraordinaria'],
        asiComentario: json['asiComentario'],
        asiFechaRegistroExtraordinaria: json['asiFechaRegistroExtraordinaria']);
  }
}
