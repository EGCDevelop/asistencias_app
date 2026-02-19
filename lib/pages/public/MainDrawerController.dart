import 'package:asistencias_egc/pages/attendanceChar/attendance_char.dart';
import 'package:asistencias_egc/pages/events/events.dart';
import 'package:asistencias_egc/pages/members/members.dart';
import 'package:asistencias_egc/pages/public/MenuLateral.dart';
import 'package:asistencias_egc/pages/public/attendance.dart';
import 'package:asistencias_egc/pages/scanner/scanner_event.dart';
import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

class MainDrawerController extends StatefulWidget {
  const MainDrawerController({super.key});

  @override
  State<MainDrawerController> createState() => _MainDrawerControllerState();
}

class _MainDrawerControllerState extends State<MainDrawerController> {
  final _zoomDrawerController = ZoomDrawerController();
  String currentScreen = "members";

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    bool isGeneral = Utils.isGeneralPerfil(authProvider.user!.puestoId);
    return PopScope(
      canPop: false,
      child: ZoomDrawer(
        controller: _zoomDrawerController,
        mainScreen: _getScreen(),
        menuScreen: MenuLateral(
          isAdmin: isGeneral,
          onRouteSelected: (route) {
            setState(() => currentScreen = route);
            _zoomDrawerController.close?.call();
          },
        ),
        borderRadius: 24.0,
        showShadow: true,
        angle: -12.0,
        drawerShadowsBackgroundColor: Colors.grey[300]!,
        slideWidth: MediaQuery.of(context).size.width * 0.76,
      ),
    );
  }

  Widget _getScreen() {
    switch (currentScreen) {
      case 'scanner_event': return const ScannerEvent();
      case 'attendance': return const Attendance();
      case 'event': return const Events();
      case 'members': return const Members();
      case 'attendance_char': return const AttendanceChar();
      default: return const Members();
    }
  }
}
