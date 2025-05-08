class Escuadras {
  final int escIdEscuadra;
  final String escNombre;

  Escuadras({required this.escIdEscuadra, required this.escNombre});

  factory Escuadras.fromJson(Map<String, dynamic> json) {
    return Escuadras(
      escIdEscuadra: json['escIdEscuadra'],
      escNombre: json['escNombre'],
    );
  }
}

