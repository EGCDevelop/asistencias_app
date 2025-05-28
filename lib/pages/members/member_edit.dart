import 'package:asistencias_egc/models/Career.dart';
import 'package:asistencias_egc/models/Establishment.dart';
import 'package:asistencias_egc/models/escuadras.dart';
import 'package:asistencias_egc/models/integrantes.dart';
import 'package:asistencias_egc/utils/api/Degrees.dart';
import 'package:asistencias_egc/utils/api/Position.dart';
import 'package:asistencias_egc/utils/api/general_methods_controllers.dart';
import 'package:asistencias_egc/utils/api/members_controller.dart';
import 'package:asistencias_egc/widgets/CustomTextField.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:flutter/material.dart';

class MemberEdit extends StatefulWidget {
  const MemberEdit({super.key});

  @override
  State<MemberEdit> createState() => _MemberEditState();
}

class _MemberEditState extends State<MemberEdit> {
  final _formKey = GlobalKey<FormState>();
  int? memberId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cellController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _fatherCellController = TextEditingController();
  final TextEditingController _anotherEstablishmentController =
      TextEditingController();
  final TextEditingController _courseName = TextEditingController();

  // Listas
  List<Escuadras> escuadras = [];
  Escuadras? selectedEscuadra;
  List<Establishment> establecimientos = [];
  Establishment? selectedEstablecimiento;
  List<Position> positions = [];
  Position? selectedPosition;
  List<Degrees> degrees = [];
  Degrees? selectedDegrees;
  List<Career> courses = [];
  Career? selectedCourse;

  bool _isLoading = false;
  bool _isNew = false;
  bool isActive = true;

  // valores
  int? initialEstablecimientoId;
  int? initialSquadId;
  int? initialPosition;
  int? initialDegree;
  int? initialCourse;

  @override
  void initState() {
    super.initState();
    _loadCombos();
  }

  Future<void> _loadCombos() async {
    setState(() {
      _isLoading = true;
    });

    final results = await Future.wait([
      GeneralMethodsControllers.GetSquads(),
      GeneralMethodsControllers.getEstablishment(),
      GeneralMethodsControllers.getDegrees(),
      GeneralMethodsControllers.getPosition(),
      GeneralMethodsControllers.getCareer(),
    ]);

    setState(() {
      escuadras = results[0] as List<Escuadras>;
      establecimientos = results[1] as List<Establishment>;
      degrees = results[2] as List<Degrees>;
      positions = results[3] as List<Position>;
      courses = results[4] as List<Career>;

      // Preselecciona el establecimiento basado en su ID
      selectedEstablecimiento = establecimientos.firstWhere(
        (est) => est.estIdEstablecimiento == initialEstablecimientoId,
        orElse: () => Establishment(
          estIdEstablecimiento: -1,
          estNombreEstablecimiento: "No encontrado",
        ),
      );
      selectedEscuadra = escuadras.firstWhere(
        (esc) => esc.escIdEscuadra == initialSquadId,
        orElse: () => Escuadras(
          escIdEscuadra: -1,
          escNombre: "No encontrado",
        ),
      );
      selectedPosition = positions.firstWhere(
        (pos) => pos.puIdPuesto == initialPosition,
        orElse: () => Position(
          puIdPuesto: -1,
          puNombre: "No encontrado",
        ),
      );
      selectedDegrees = degrees.firstWhere(
        (deg) => deg.graIdGrado == initialDegree,
        orElse: () => Degrees(
          graIdGrado: -1,
          graNombreGrado: "No encontrado",
        ),
      );

      selectedCourse = courses.firstWhere(
        (course) => course.carIdCarrera == initialCourse,
        orElse: () => Career(
          carIdCarrera: -1,
          carNombreCarrera: "No encontrado",
        ),
      );

      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args is Integrantes) {
      memberId = args.intIdIntegrante;
      _nameController.text = args.intNombres;
      _lastNameController.text = args.intApellidos;
      _cellController.text = args.intTelefono;
      _sectionController.text = args.intSeccion;
      _isNew = args.intEsNuevo == 1 ? true : false;
      _fatherNameController.text = args.intNombreEncargado;
      _fatherCellController.text = args.intTelefonoEncargado;
      _anotherEstablishmentController.text = args.intEstablecimientoNombre;
      initialEstablecimientoId = args.intestIdEstablecimiento;
      initialSquadId = args.intescIdEscuadra;
      initialPosition = args.intpuIdPuesto;
      initialDegree = args.intgraIdGrado;
      initialCourse = args.intcarIdCarrera;
      _isNew = args.intEsNuevo == 1;
      isActive = args.intEstadoIntegrante == 1;
      _courseName.text = args.intCarreraNombre;
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool success = await MembersController.updateMember(
          memberId: memberId!,
          firstName: _nameController.text,
          lastName: _lastNameController.text,
          cellPhone: _cellController.text,
          squadId: selectedEscuadra!.escIdEscuadra,
          positionId: selectedPosition!.puIdPuesto,
          isActive: isActive ? 1 : 0,
          isAncient: _isNew ? 1 : 0,
          establecimientoId: selectedEstablecimiento!.estIdEstablecimiento,
          anotherEstablishment: _anotherEstablishmentController.text.isEmpty
              ? ""
              : _anotherEstablishmentController.text,
          courseId: selectedCourse!.carIdCarrera,
          courseName: _courseName.text.isEmpty ? "" : _courseName.text,
          degreeId: selectedDegrees!.graIdGrado,
          section: _sectionController.text,
          fatherName: _fatherNameController.text,
          fatherCell: _fatherCellController.text);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Registro actualizado exitosamente"
              : "Error al actualizar"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Future.delayed(const Duration(milliseconds: 100), () {
          // Espera breve para ver el mensaje
          Navigator.pop(context, true); // Regresa a la pantalla anterior
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopScope(
          child: Scaffold(
            appBar: AppBar(title: const Text("Editar integrante")),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      _titles('Datos de integrante'),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nombre',
                        icon: Icons.title,
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: _lastNameController,
                        label: 'Apellidos',
                        icon: Icons.title,
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa apellido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: _cellController,
                        label: 'Teléfono',
                        icon: Icons.phone_android,
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un télefono';
                          }
                          return null;
                        },
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
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 5),
                                  child: DropdownButton<Escuadras>(
                                    isExpanded: true,
                                    value: selectedEscuadra,
                                    onChanged: (Escuadras? newValue) {
                                      setState(() {
                                        selectedEscuadra = newValue;
                                      });
                                    },
                                    items: escuadras.map((escuadra) {
                                      return DropdownMenuItem<Escuadras>(
                                        value: escuadra,
                                        child: Text(
                                          escuadra.escNombre,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    underline: Container(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Puesto",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 5),
                                  child: DropdownButton<Position>(
                                    isExpanded: true,
                                    value: selectedPosition,
                                    onChanged: (Position? newValue) {
                                      setState(() {
                                        selectedPosition = newValue;
                                      });
                                    },
                                    items: positions.map((position) {
                                      return DropdownMenuItem<Position>(
                                        value: position,
                                        child: Text(
                                          position.puNombre,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    underline: Container(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          buildStatusCard(
                            "Activo",
                            Icons.check_circle,
                            isActive,
                            () => setState(() => isActive = true),
                          ),
                          const SizedBox(width: 12),
                          buildStatusCard("Inactivo", Icons.cancel, !isActive,
                              () => setState(() => isActive = false)),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          buildStatusCard("Nuevo", Icons.hourglass_full, _isNew,
                              () => setState(() => _isNew = true)),
                          const SizedBox(width: 12),
                          buildStatusCard("Antiguo", Icons.hourglass_bottom,
                              !_isNew, () => setState(() => _isNew = false)),
                        ],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      _titles('Carrera'),
                      const SizedBox(
                        height: 30,
                      ),
                      Column(
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
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 5),
                            child: DropdownButton<Establishment>(
                              isExpanded: true,
                              value: selectedEstablecimiento,
                              onChanged: (Establishment? newValue) {
                                setState(() {
                                  selectedEstablecimiento = newValue;
                                });
                              },
                              items: establecimientos.map((establishment) {
                                return DropdownMenuItem<Establishment>(
                                  value: establishment,
                                  child: Text(
                                    establishment.estNombreEstablecimiento,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              underline: Container(),
                            ),
                          ),
                        ],
                      ),
                      selectedEstablecimiento?.estIdEstablecimiento == 3
                          ? const SizedBox(
                              height: 20,
                            )
                          : Container(),
                      selectedEstablecimiento?.estIdEstablecimiento == 3
                          ? CustomTextField(
                              controller: _anotherEstablishmentController,
                              label: 'Nombre establecimiento',
                              icon: Icons.home_work,
                              isPassword: false,
                              validator: (value) {
                                if (selectedEstablecimiento
                                        ?.estIdEstablecimiento ==
                                    3) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa un establecimiento';
                                  }
                                }
                                return null;
                              },
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Carrera",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 5),
                            child: DropdownButton<Career>(
                              isExpanded: true,
                              value: selectedCourse,
                              onChanged: (Career? newValue) {
                                setState(() {
                                  selectedCourse = newValue;
                                });
                              },
                              items: courses.map((course) {
                                return DropdownMenuItem<Career>(
                                  value: course,
                                  child: Text(
                                    course.carNombreCarrera,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              underline: Container(),
                            ),
                          ),
                        ],
                      ),
                      selectedCourse?.carIdCarrera == 6
                          ? const SizedBox(
                              height: 20,
                            )
                          : Container(),
                      selectedCourse?.carIdCarrera == 6
                          ? CustomTextField(
                              controller: _courseName,
                              label: 'Nombre carrera',
                              icon: Icons.home_work,
                              isPassword: false,
                              validator: (value) {
                                if (selectedCourse?.carIdCarrera == 6) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa una carrera';
                                  }
                                }
                                return null;
                              },
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Grado",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 5),
                            child: DropdownButton<Degrees>(
                              isExpanded: true,
                              value: selectedDegrees,
                              onChanged: (Degrees? newValue) {
                                setState(() {
                                  selectedDegrees = newValue;
                                });
                              },
                              items: degrees.map((degree) {
                                return DropdownMenuItem<Degrees>(
                                  value: degree,
                                  child: Text(
                                    degree.graNombreGrado,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              underline: Container(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: _sectionController,
                        label: 'Sección',
                        icon: Icons.abc,
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una sección';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      _titles('Otros datos'),
                      const SizedBox(
                        height: 40,
                      ),
                      CustomTextField(
                        controller: _fatherNameController,
                        label: 'Encargado',
                        icon: Icons.person,
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: _fatherCellController,
                        label: 'Teléfono encargado',
                        icon: Icons.phone,
                        isPassword: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un teléfono';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _handleUpdate,
                          child: const Text(
                            "Guardar",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) LoadingAnimation(),
      ],
    );
  }

  Widget _titles(String text) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      width: double.infinity,
      child: Text(text),
    );
  }

  Widget buildStatusCard(
      String label, IconData icon, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // Ejecuta la función que cambia el estado
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? Colors.white : Colors.black, size: 28),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
