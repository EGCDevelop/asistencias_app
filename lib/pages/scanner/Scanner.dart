import 'package:asistencias_egc/provider/AuthProvider.dart';
import 'package:asistencias_egc/utils/api/scanner_controller.dart';
import 'package:asistencias_egc/widgets/CustomAppBar.dart';
import 'package:asistencias_egc/widgets/LoadingAnimation.dart';
import 'package:asistencias_egc/widgets/animation/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _screenOpened = false;
  int? eventId;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is int) {
      eventId = args;
    }
  }

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

  void _foundBarcode2(BarcodeCapture capture, int escuadraComandante,
      int puestoComandante, String token, int id) async {
    if (!_screenOpened) {
      final Barcode? barcode = capture.barcodes.firstOrNull;
      final String code = barcode?.rawValue ?? '----';

      if (barcode == null || barcode.rawValue == null || int.tryParse(code) == null) {
        CustomSnackBar.show(
          context,
          success: false,
          message: "Código inválido.",
        );
      } else {
        setState(() {
          isLoading = true;
        });
        _screenOpened = true;

        final result = await ScannerController.registerAttendance(
          id: code,
          escuadra: escuadraComandante.toString(),
          puesto: puestoComandante.toString(),
          token: token,
          eventId: eventId.toString(),
          idRegistro: id.toString(),
        );

        CustomSnackBar.show(
          context,
          success: true,
          message: result['message'],
        );

        // Reiniciar la cámara para permitir nueva lectura
        _screenOpened = false;
        setState(() {
          isLoading = false;
        });

        await Future.delayed(const Duration(milliseconds: 500)); // Pequeña pausa
        cameraController.start(); // Reactivar la cámara
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
        appBar: const CustomAppBar(title: 'Scanner'),
        body: Stack(
          children: <Widget>[
            MobileScanner(
              controller: cameraController,
              onDetect: (barcodes) => _foundBarcode2(barcodes, user!.escuadraId,
                  user.puestoId, user.token, user.idIntegrante),
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
                      border: Border.all(color: Colors.red, width: 3),
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
            if (isLoading) LoadingAnimation(),
          ],
        ),
      ),
    );
  }
}
