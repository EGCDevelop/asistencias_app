import 'package:asistencias_egc/models/Establishment.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/models/integrantes.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/utils/api/members_controller.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  List<Integrantes> generalData = [];
  List<Escuadras> escuadras = [];
  Escuadras? selectedEscuadra;

  List<Establishment> establecimientos = [];
  Establishment? selectedEstablecimiento;

  // Definimos las listas con los valores y sus etiquetas
  final List<Map<String, dynamic>> states = [
    {"id": 0, "name": "De baja"},
    {"id": 1, "name": "Activos"}
  ];

  final List<Map<String, dynamic>> news = [
    {"id": 0, "name": "Antiguos"},
    {"id": 1, "name": "Nuevo"},
    {"id": 2, "name": "Todos"}
  ];

  // Variables para almacenar las selecciones
  int selectedState = 1; // Por defecto "Activos"
  int selectedNews = 2; // Por defecto "Todos"
  bool _isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCombos();
    _getData();
  }

  Future<void> _loadCombos() async {
    setState(() {
      _isLoading = true;
    });

    List<Escuadras> squads = await GeneralMethodsControllers.GetSquads();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    int userEscuadraId = authProvider.user!.escuadraId;

    List<Establishment> establishments =
        await GeneralMethodsControllers.getEstablishment();
    // Agregar "Todos" con ID 0 al inicio de la lista
    establishments.insert(
        0,
        Establishment(
            estNombreEstablecimiento: "Todos", estIdEstablecimiento: 0));

    setState(() {
      if (userEscuadraId == 1 || userEscuadraId == 12) {
        escuadras = squads.where((e) => e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 14).toList();
      } else if (userEscuadraId == 2 || userEscuadraId == 13) {
        escuadras = squads.where((e) => e.escIdEscuadra == userEscuadraId || e.escIdEscuadra == 15).toList();
      } else if (userEscuadraId == 11) {
        escuadras = squads;
      } else {
        escuadras = squads.where((e) => e.escIdEscuadra == userEscuadraId).toList();
      }

      if (userEscuadraId == 11) {
        selectedEscuadra = escuadras.firstWhere(
              (e) => e.escIdEscuadra == 1,
          orElse: () => escuadras.first,
        );
      } else {
        selectedEscuadra = escuadras.firstWhere(
              (e) => e.escIdEscuadra == userEscuadraId,
          orElse: () => escuadras.first,
        );
      }

      establecimientos = establishments;
      selectedEstablecimiento = establishments
          .first;
      _isLoading = false;
    });

    _getData();
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });

    String searchQuery = searchController.text.trim().isNotEmpty
        ? searchController.text.trim()
        : "%";

    int escuadraId = selectedEscuadra?.escIdEscuadra ?? 1;
    int establecimientoId = selectedEstablecimiento?.estIdEstablecimiento ?? 0;
    int estado = selectedState;
    int esNuevo = selectedNews;

    List<Integrantes> integrantes = await MembersController.getMemberLike(
      like: searchQuery,
      squadId: escuadraId,
      schoolId: establecimientoId,
      isNew: esNuevo,
      memberState: estado,
    );

    setState(() {
      debugPrint("integrantes == ${integrantes.length}");
      _isLoading = false;
      generalData = integrantes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopScope(
          canPop: false,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Integrantes'),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar por nombre...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () => _getData(),
                      ),
                      border: const UnderlineInputBorder(),
                      // Solo línea inferior
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black, width: 2), // Estilo al enfocar
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Escuadra",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<Escuadras>(
                                isExpanded: true,
                                value: selectedEscuadra,
                                onChanged: (Escuadras? newValue) {
                                  setState(() {
                                    selectedEscuadra = newValue;
                                  });
                                  _getData();
                                },
                                items: escuadras.map((escuadra) {
                                  return DropdownMenuItem<Escuadras>(
                                    value: escuadra,
                                    child: Text(
                                      escuadra.escNombre,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: Colors.black,
                                underline: Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Espaciado entre ambos Dropdowns
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Establecimiento",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<Establishment>(
                                isExpanded: true,
                                value: selectedEstablecimiento,
                                onChanged: (Establishment? newValue) {
                                  setState(() {
                                    selectedEstablecimiento = newValue;
                                  });
                                  _getData();
                                },
                                items: establecimientos.map((establishment) {
                                  return DropdownMenuItem<Establishment>(
                                    value: establishment,
                                    child: Text(
                                      establishment.estNombreEstablecimiento,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: Colors.black,
                                underline: Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Estado",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedState,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedState = newValue!;
                                  });
                                  _getData();
                                },
                                items: states.map((state) {
                                  return DropdownMenuItem<int>(
                                    value: state["id"],
                                    child: Text(
                                      state["name"],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: Colors.black,
                                underline: Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nuevo",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedNews,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedNews = newValue!;
                                  });
                                  _getData();
                                },
                                items: news.map((newsItem) {
                                  return DropdownMenuItem<int>(
                                    value: newsItem["id"],
                                    child: Text(
                                      newsItem["name"],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: Colors.black,
                                underline: Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text('Total: ${generalData.length}'),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  membersTable(context, generalData, _getData),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }
}

Widget membersTable(BuildContext context, List<Integrantes> dataList,
    VoidCallback refreshData) {
  return Expanded(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
            columnSpacing: 30,
            headingRowColor:
                WidgetStateProperty.resolveWith((states) => Colors.black),
            columns: const [
              DataColumn(
                label: Text(
                  "Edit",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Nombre",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Teléfono",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Establecimiento",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Otro establecimiento",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Carrera",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Otra Carrera",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Grado",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Sección",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Escuadra",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Nuevo",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Encargado",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Teléfono encargado",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Puesto",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: dataList.map((member) {
              return DataRow(
                cells: [
                  DataCell(
                    const Text(""),
                    showEditIcon: true,
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                          context, "member_edit",
                          arguments: member);

                      if (result == true) {
                        refreshData();
                      }
                    },
                  ),
                  DataCell(Text("${member.intNombres} ${member.intApellidos}")),
                  DataCell(Text(member.intTelefono)),
                  DataCell(Text(member.estNombreEstablecimiento)),
                  DataCell(Text(member.intEstablecimientoNombre)),
                  DataCell(Text(member.carNombreCarrera)),
                  DataCell(Text(member.intCarreraNombre)),
                  DataCell(Text(member.graNombreGrado)),
                  DataCell(Text(member.intSeccion)),
                  DataCell(Text(member.escNombre)),
                  DataCell(Text(member.intEsNuevo == 1 ? "Si" : "No")),
                  DataCell(Text(member.intNombreEncargado)),
                  DataCell(Text(member.intTelefonoEncargado)),
                  DataCell(Text(member.puNombre)),
                ],
              );
            }).toList()),
      ),
    ),
  );
}
