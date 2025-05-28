class Career {
  final int carIdCarrera;
  final String carNombreCarrera;

  Career({required this.carIdCarrera, required this.carNombreCarrera});

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      carIdCarrera: json['carIdCarrera'],
      carNombreCarrera: json['carNombreCarrera'],
    );
  }
}
