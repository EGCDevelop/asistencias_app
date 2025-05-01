import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/widgets/animation/AnimationGenerator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Tomar asistencia', 'icon': Icons.qr_code, 'route': 'scanner'},
    {'title': 'Ver asistencia', 'icon': Icons.list_alt, 'route': 'attendance'},
  ];


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
/*    var authProvider = Provider.of<AuthProvider>(context);
    var user = authProvider.user;
    List<String> firstName = user!.nombres.split(" ");
    List<String> lastName = user!.apellidos.split(" ");
    String titleName = "${firstName[0]} ${lastName[0]}";*/
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.05),
                Center(
                  child: Text(
                    //titleName,
                    'ERICK OSOY',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    var item = menuItems[index];
                    bool isLeft = index % 2 == 0 ? true : false;
                    return AnimationGenerator(
                      duration: const Duration(seconds: 1),
                      delay: const Duration(seconds: 0),
                      isLeft: isLeft,
                      child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black, // Fondo negro
                            borderRadius: BorderRadius.circular(10), // Bordes redondeados
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item['icon'], color: Colors.white, size: 35),
                              const SizedBox(height: 10),
                              Text(
                                item['title'],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),

                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
