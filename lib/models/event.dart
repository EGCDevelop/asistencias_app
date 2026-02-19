class Event {
  final int eveId;
  final String eveTitulo;
  final String eveDescripcion;
  final String eveFechaEvento;
  final String eveHoraEntradaComandantes;
  final int eveSoloComandantes;
  final String? eveHoraEntradaIntegrantes;
  final String eveUsuarioCreacion;
  final String eveFechaCreacion;
  final String? eveUsuarioModificacion;
  final String eveFechaModificacon;
  final int eveBandaGeneral;
  final String? listadoEscuadras;

  Event({
    required this.eveId,
    required this.eveTitulo,
    required this.eveDescripcion,
    required this.eveFechaEvento,
    required this.eveHoraEntradaComandantes,
    required this.eveSoloComandantes,
    this.eveHoraEntradaIntegrantes,
    required this.eveUsuarioCreacion,
    required this.eveFechaCreacion,
    this.eveUsuarioModificacion,
    required this.eveFechaModificacon,
    required this.eveBandaGeneral,
    this.listadoEscuadras
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eveId: json['eveId'],
      eveTitulo: json['eveTitulo'],
      eveDescripcion: json['eveDescripcion'],
      eveFechaEvento: json['eveFechaEvento'],
      eveHoraEntradaComandantes: json['eveHoraEntradaComandantes'],
      eveSoloComandantes: json['eveSoloComandantes'],
      eveHoraEntradaIntegrantes: json['eveHoraEntradaIntegrantes'],
      eveUsuarioCreacion: json['eveUsuarioCreacion'],
      eveFechaCreacion: json['eveFechaCreacion'],
      eveUsuarioModificacion: json['eveUsuarioModificacion'],
      eveFechaModificacon: json['eveFechaModificacon'],
      eveBandaGeneral: json["eveBandaGeneral"],
      listadoEscuadras: json['listadoEscuadras'],
    );
  }

  List<int> get idsEscuadras {
    if (listadoEscuadras == null || listadoEscuadras!.isEmpty) return [];
    return listadoEscuadras!
        .split(',')
        .map((s) => int.parse(s.trim()))
        .toList();
  }
}

