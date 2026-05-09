import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/login_controller.dart';
import 'package:asistencias_egc/utils/utils.dart';
import 'package:asistencias_egc/widgets/CustomTextField.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/FadeInUp.dart';
import 'package:asistencias_egc/widgets/animation/OpacityAnimation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Mostrar el loading
      });

      var result = await LoginController.login(
          _userController.text, _passwordController.text, Utils.APP_VERSION);

      setState(() {
        _isLoading = false; // Ocultar el loading
      });

      if (result['success']) {
        Provider.of<AuthProvider>(context, listen: false)
            .setUser(result['data']);
        // Navegar hacia 'menu'
        Navigator.pushNamed(context, 'menu');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleBiometricLogin() async {
    final LocalAuthentication auth = LocalAuthentication();
    final prefs = await SharedPreferences.getInstance();
    final int biometricStatus = prefs.getInt('isBiometricEnabled') ?? 0;

    if (biometricStatus == 1) {
      try {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Autentíquese para acceder al sistema',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );

        if (authenticated) {
          int? savedId = prefs.getInt('savedMemberId');
          String? savedToken = prefs.getString('biometricToken');
          String? savedUsername = prefs.getString(
              'username');

          if (savedId != null && savedToken != null) {
            setState(() => _isLoading = true);

            var result = await LoginController.biometricLogin(
                savedId, savedUsername ?? "", savedToken, Utils.APP_VERSION);

            setState(() => _isLoading = false);

            if (result['success']) {
              Provider.of<AuthProvider>(context, listen: false)
                  .setUser(result['data']);

              Navigator.pushNamed(context, 'menu');
            } else {
              _showSnackBar(result['message'], Colors.red);
            }
          } else {
            _showSnackBar(
                "Información de sesión incompleta. Inicie sesión manualmente.",
                Colors.orange);
          }
        }
      } catch (e) {
        _showSnackBar("Error de autenticación: $e", Colors.red);
      }
    } else {
      _showSnackBar(
          "Debe ingresar a su perfil y activar la autenticación biométrica",
          Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        PopScope(
          canPop: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInUp(
                          duration: const Duration(seconds: 1),
                          delay: const Duration(seconds: 0),
                          child: Image.asset(
                            'assets/escudo.png',
                            width: size.width * 0.45,
                            height: size.height * 0.3,
                            fit: BoxFit.contain,
                          ),
                        ),
                        OpacityAnimation(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 700),
                          child: CustomTextField(
                            controller: _userController,
                            label: 'Usuario',
                            icon: Icons.person,
                            isPassword: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu usuario';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        OpacityAnimation(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 900),
                          child: CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            isPassword: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              return null;
                            },
                          ),
                        ),
                        OpacityAnimation(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 1100),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isPasswordVisible,
                                activeColor: Colors.black,
                                onChanged: (value) {
                                  setState(() {
                                    _isPasswordVisible = value!;
                                  });
                                },
                              ),
                              const Text("Mostrar contraseña"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        OpacityAnimation(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 1100),
                          child: IconButton(
                            icon: const Icon(Icons.fingerprint,
                                size: 55, color: Colors.black),
                            onPressed: _handleBiometricLogin,
                          ),
                        ),
                        const SizedBox(height: 40),
                        OpacityAnimation(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 1300),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _handleLogin,
                              child: const Text(
                                "INICIAR SESIÓN",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const OpacityAnimation(
                          duration: Duration(milliseconds: 1000),
                          delay: Duration(milliseconds: 1500),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  'v${Utils.APP_VERSION}',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
}
