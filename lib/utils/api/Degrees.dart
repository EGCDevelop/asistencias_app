class Degrees {
  final int graIdGrado;
  final String graNombreGrado;

  Degrees({required this.graIdGrado, required this.graNombreGrado});

  factory Degrees.fromJson(Map<String, dynamic> json) {
    return Degrees(
      graIdGrado: json['graIdGrado'],
      graNombreGrado: json['graNombreGrado'],
    );
  }
}
