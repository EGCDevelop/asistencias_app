class Integrantes {
  final int intIdIntegrante;
  final String intNombres;
  final String intApellidos;
  final String intTelefono;
  final int intestIdEstablecimiento;
  final String estNombreEstablecimiento;
  final String intEstablecimientoNombre;
  final int intcarIdCarrera;
  final String carNombreCarrera;
  final String intCarreraNombre;
  final int intgraIdGrado;
  final String graNombreGrado;
  final String intGradoNombre;
  final String intSeccion;
  final int intescIdEscuadra;
  final String escNombre;
  final int intEsNuevo;
  final String intNombreEncargado;
  final String intTelefonoEncargado;
  final int intEstadoIntegrante;
  final int intpuIdPuesto;
  final String puNombre;

  Integrantes({
    required this.intIdIntegrante,
    required this.intNombres,
    required this.intApellidos,
    required this.intTelefono,
    required this.intestIdEstablecimiento,
    required this.estNombreEstablecimiento,
    required this.intEstablecimientoNombre,
    required this.intcarIdCarrera,
    required this.carNombreCarrera,
    required this.intCarreraNombre,
    required this.intgraIdGrado,
    required this.graNombreGrado,
    required this.intGradoNombre,
    required this.intSeccion,
    required this.intescIdEscuadra,
    required this.escNombre,
    required this.intEsNuevo,
    required this.intNombreEncargado,
    required this.intTelefonoEncargado,
    required this.intEstadoIntegrante,
    required this.intpuIdPuesto,
    required this.puNombre,
  });

  factory Integrantes.fromJson(Map<String, dynamic> json) {
    return Integrantes(
      intIdIntegrante: json['intIdIntegrante'],
      intNombres: json['intNombres'],
      intApellidos: json['intApellidos'],
      intTelefono: json['intTelefono'],
      intestIdEstablecimiento: json['intestIdEstablecimiento'],
      estNombreEstablecimiento: json['estNombreEstablecimiento'],
      intEstablecimientoNombre: json['intEstablecimientoNombre'],
      intcarIdCarrera: json['intcarIdCarrera'],
      carNombreCarrera: json['carNombreCarrera'],
      intCarreraNombre: json['intCarreraNombre'],
      intgraIdGrado: json['intgraIdGrado'],
      graNombreGrado: json['graNombreGrado'],
      intGradoNombre: json['intGradoNombre'],
      intSeccion: json['intSeccion'],
      intescIdEscuadra: json['intescIdEscuadra'],
      escNombre: json['escNombre'],
      intEsNuevo: json['intEsNuevo'],
      intNombreEncargado: json['intNombreEncargado'],
      intTelefonoEncargado: json['intTelefonoEncargado'],
      intEstadoIntegrante: json['intEstadoIntegrante'],
      intpuIdPuesto: json['intpuIdPuesto'],
      puNombre: json['puNombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intIdIntegrante': intIdIntegrante,
      'intNombres': intNombres,
      'intApellidos': intApellidos,
      'intTelefono': intTelefono,
      'intestIdEstablecimiento': intestIdEstablecimiento,
      'estNombreEstablecimiento': estNombreEstablecimiento,
      'intEstablecimientoNombre': intEstablecimientoNombre,
      'intcarIdCarrera': intcarIdCarrera,
      'carNombreCarrera': carNombreCarrera,
      'intCarreraNombre': intCarreraNombre,
      'intgraIdGrado': intgraIdGrado,
      'graNombreGrado': graNombreGrado,
      'intGradoNombre': intGradoNombre,
      'intSeccion': intSeccion,
      'intescIdEscuadra': intescIdEscuadra,
      'escNombre': escNombre,
      'intEsNuevo': intEsNuevo,
      'intNombreEncargado': intNombreEncargado,
      'intTelefonoEncargado': intTelefonoEncargado,
      'intEstadoIntegrante': intEstadoIntegrante,
      'intpuIdPuesto': intpuIdPuesto,
      'puNombre': puNombre,
    };
  }
}
