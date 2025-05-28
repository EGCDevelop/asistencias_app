class Establishment {
  final int estIdEstablecimiento;
  final String estNombreEstablecimiento;

  Establishment(
      {required this.estIdEstablecimiento,
      required this.estNombreEstablecimiento});

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      estIdEstablecimiento: json['estIdEstablecimiento'],
      estNombreEstablecimiento: json['estNombreEstablecimiento'],
    );
  }
}
