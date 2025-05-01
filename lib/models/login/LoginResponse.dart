class LoginResponse {
  final bool ok;
  final int idIntegrante;
  final String nombres;
  final String apellidos;
  final int escuadraId;
  final int puestoId;
  final String token;

  LoginResponse({
    required this.ok,
    required this.idIntegrante,
    required this.nombres,
    required this.apellidos,
    required this.escuadraId,
    required this.puestoId,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      ok: json['ok'] ?? false,
      idIntegrante: json['intIdIntegrante'] ?? 0,
      nombres: json['intNombres'] ?? '',
      apellidos: json['intApellidos'] ?? '',
      escuadraId: json['intescIdEscuadra'] ?? 0,
      puestoId: json['intpuIdPuesto'] ?? 0,
      token: json['token'] ?? '',
    );
  }
}