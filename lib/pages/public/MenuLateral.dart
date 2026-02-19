import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuLateral extends StatelessWidget {
  final Function(String) onRouteSelected;
  final bool isAdmin;
  const MenuLateral({super.key, required this.onRouteSelected, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var authProvider = Provider.of<AuthProvider>(context);
    var user = authProvider.user;
    List<String> firstName = user!.nombres.split(" ");
    List<String> lastName = user!.apellidos.split(" ");
    String titleName = "${firstName[0]} ${lastName[0]}";

    final List<Map<String, dynamic>> allMenuItems = [
      {'title': 'Tomar asistencia', 'icon': Icons.qr_code, 'route': 'scanner_event'},
      {'title': 'Ver asistencia', 'icon': Icons.list_alt, 'route': 'attendance'},
      {'title': 'Eventos', 'icon': Icons.calendar_month, 'route': 'event'},
      {'title': 'Integrantes', 'icon': Icons.person, 'route': 'members'},
      {'title': 'Gráfica', 'icon': Icons.pie_chart, 'route': 'attendance_char'},
    ];

    final menuItems = allMenuItems.where((item) {
      if (item['route'] == 'attendance_char') {
        return isAdmin; // Solo true si es puesto 1, 2, 3 o 4
      }
      return true; // El resto de opciones son siempre visibles
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black, // Fondo total negro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/escudo.png',
                width: size.width * 0.35,
                height: size.height * 0.2,
                fit: BoxFit.contain,
              ),
              Text(
                titleName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                Utils.getSquadName(user.puestoId),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white24),
              // Lista de opciones
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    var item = menuItems[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      leading: Icon(item['icon'], color: Colors.white, size: 20),
                      title: Text(
                        item['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      onTap: () => onRouteSelected(item['route']),
                    );
                  },
                ),
              ),

              // Botón de cerrar sesión al final
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
                onTap: () {
                  // Aquí tu lógica de logout
                  Navigator.pushReplacementNamed(context, 'login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
