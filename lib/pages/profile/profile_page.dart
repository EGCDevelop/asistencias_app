import 'package:asistencias_egc/models/login/LoginResponse.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/members_controller.dart';
import 'package:asistencias_egc/utils/utils.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/CustomSwitch.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  bool enabledBiometric = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  void _loadBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int biometricStatus = prefs.getInt('isBiometricEnabled') ?? 2;

    setState(() {
      enabledBiometric = (biometricStatus == 1);
    });
  }

  void _handleBiometricLogin(bool value) async {
    final LocalAuthentication auth = LocalAuthentication();
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    LoginResponse loginResponse = authProvider.user!;

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentíquese para iniciar sesión',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        setState(() => isLoading = true);
        var result = await MembersController.updateMemberBiometric(
          memberId: loginResponse.idIntegrante,
          biometricEnabled: value ? 1 : 2
        );

        setState(() {
          isLoading = false;
        });

        if (result != null && result['ok'] == true) {
          final prefs = await SharedPreferences.getInstance();

          if (value) {
            // Si activó: Guardamos estado 1, el ID y el Token que vino del server
            await prefs.setInt('isBiometricEnabled', 1);
            await prefs.setInt('savedMemberId', loginResponse.idIntegrante);
            await prefs.setString('biometricToken', result['nuevoToken']);
            await prefs.setString('username', loginResponse.username);

          } else {
            // Si desactivó: Limpiamos o ponemos en estado 2
            await prefs.setInt('isBiometricEnabled', 2);
            await prefs.remove('biometricToken');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Configuración biométrica actualizada con éxito"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo actualizar la configuración en el servidor"),
              backgroundColor: Colors.red,
            ),
          );

          setState(() => enabledBiometric = !value);
        }
      }
    } catch (e) {
      print('error = $e');
      _showError("Error de autenticación: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    LoginResponse dataUser = authProvider.user!;
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        PopScope(
          canPop: false,
          child: Scaffold(
            appBar: const CustomAppBar(title: ''),
            body: Column(
              // Esta línea centra los hijos horizontalmente en la columna
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: double.infinity),
                Container(
                  width: size.width * 0.85,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        dataUser.nombres,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dataUser.apellidos,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        Utils.getSquadName(dataUser.puestoId),
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.075),
                  child: Column(
                    children: <Widget>[
                      CustomSwitch(
                        label: "Habilitar biometría",
                        icon: Icons.fingerprint_outlined,
                        value: enabledBiometric,
                        // onChanged: (val) {
                        //   setState(() => enabledBiometric = val);
                        // },
                        onChanged: (value) => _handleBiometricLogin(value),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        if (isLoading) LoadingAnimation(),
      ],
    );
  }
}
