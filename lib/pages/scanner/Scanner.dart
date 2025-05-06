import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/scanner_controller.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  //MobileScannerController cameraController = MobileScannerController();
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // Evita múltiples detecciones
  );
  bool _screenOpened = false;

  @override
  void initState() {
    super.initState();
    cameraController.start(); // Reiniciar la cámara al entrar en la pantalla
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), ),
      snackBarAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 300), // Duración de la animación
      )
    );
  }

  void _foundBarcode(BarcodeCapture capture, int escuadraComandante, int puestoComandante, String token) async {
    if (!_screenOpened) {
      final Barcode? barcode = capture.barcodes.firstOrNull;
      final String code = barcode?.rawValue ?? '----';
      if (barcode == null || barcode.rawValue == null || int.tryParse(code) == null) {
        _showSnackBar('Código inválido');
      } else {
        _screenOpened = true;
        cameraController.stop(); // Detener la cámara antes de navegar

        final result = await ScannerController.registerAttendance(
          id: code,
          escuadra: escuadraComandante.toString(),
          puesto: puestoComandante.toString(),
          token: token
        );
        _showSnackBar(result['message']);
        Navigator.popAndPushNamed(context, "menu", arguments: code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var authProvider = Provider.of<AuthProvider>(context);
    var user = authProvider.user;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SCANNER'),
        ),
        body: Stack(
          children: <Widget>[
            MobileScanner(
              controller: cameraController,
              onDetect: (barcodes) => _foundBarcode(
                barcodes,
                user!.escuadraId,
                user.puestoId,
                user.token
              ),
            ),
            Positioned(
              top: size.height * 0.25,
              right: size.width * 0.22,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(80),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.red,
                          width: 3
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder(
                          valueListenable: cameraController.torchState,
                          builder: (context, state, child) {
                            switch (state) {
                              case TorchState.off:
                                return const Icon(Icons.flash_off,
                                    color: Colors.yellow);
                              case TorchState.on:
                                return const Icon(Icons.flash_on,
                                    color: Colors.yellow);
                            }
                          },
                        ),
                        iconSize: 40.0,
                        onPressed: () => cameraController.toggleTorch(),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        color: Colors.blue,
                        icon: ValueListenableBuilder(
                          valueListenable: cameraController.cameraFacingState,
                          builder: (context, state, child) {
                            switch (state) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 40.0,
                        onPressed: () => cameraController.switchCamera(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
