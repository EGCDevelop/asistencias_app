class Position {
  final int puIdPuesto;
  final String puNombre;

  Position({required this.puIdPuesto, required this.puNombre});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      puIdPuesto: json['puIdPuesto'],
      puNombre: json['puNombre'],
    );
  }
}
