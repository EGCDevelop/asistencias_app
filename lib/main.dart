import 'package:asistencias_egc/pages/auth/login.dart';
import 'package:asistencias_egc/pages/public/attendance.dart';
import 'package:asistencias_egc/pages/public/menu.dart';
import 'package:asistencias_egc/pages/scanner/Scanner.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/Environments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  await Environments.initEnvironment();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo modo vertical
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Agregar AuthProvider
      ],
      child: const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App EGC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionHandleColor: Colors.black
        )
      ),
      initialRoute: 'login',
      routes: {
        'login': (context) => const Login(),
        'menu' : (context) => const Menu(),
        'scanner' : (context) => const Scanner(),
        'attendance': (context) => const Attendance(),
      },
    );
  }
}
