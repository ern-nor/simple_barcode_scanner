import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner_plus/constant.dart';
import 'package:simple_barcode_scanner_plus/enum.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as html;

import '../barcode_appbar.dart';
import 'barcode_controller.dart';

/// Barcode scanner for web using iframe
class WebBarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final CameraFace cameraFace;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
  final Widget? child;
  final BarcodeAppBar? barcodeAppBar;
  final int? delayMillis;
  final Function? onClose;
  final ScanFormat scanFormat;

  const WebBarcodeScanner({
    super.key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    this.cameraFace = CameraFace.back,
    required this.onScanned,
    this.appBarTitle,
    this.centerTitle,
    this.child,
    this.barcodeAppBar,
    this.delayMillis,
    this.onClose,
    this.scanFormat = ScanFormat.ALL_FORMATS,
  });

  @override
  Widget build(BuildContext context) {
    String createdViewId = DateTime.now().microsecondsSinceEpoch.toString();
    String? barcodeNumber;

    final iframe = html.HTMLIFrameElement()
      ..src = PackageConstant.barcodeFileWebPath
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..onLoad.listen((event) async {
        /// Barcode listener on success barcode scanned
        html.window.onMessage.listen((event) {
          /// If barcode is null then assign scanned barcode
          /// and close the screen otherwise keep scanning
          if (barcodeNumber == null) {
            barcodeNumber = event.data.toString();
            onScanned(barcodeNumber!);
          }
        });
      });
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(createdViewId, (int viewId) => iframe);

    final width = MediaQuery.of(context).size.width;

    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height,
      width: width,
      child: HtmlElementView(
        viewType: createdViewId,
      ),
    );
  }
}

typedef BarcodeScannerViewCreated = void Function(
    BarcodeViewController controller);

class BarcodeScannerView extends StatelessWidget {
  final BarcodeScannerViewCreated onBarcodeViewCreated;
  final ScanType scanType;
  final CameraFace cameraFace;
  final Function(String)? onScanned;
  final Widget? child;
  final int? delayMillis;
  final Function? onClose;
  final bool continuous;
  final double? scannerWidth;
  final double? scannerHeight;
  final ScanFormat scanFormat;
  const BarcodeScannerView(
      {super.key,
      this.scannerWidth,
      this.scannerHeight,
      required this.scanType,
      this.cameraFace = CameraFace.back,
      required this.onScanned,
      this.continuous = false,
      this.child,
      this.delayMillis,
      this.onClose,
      this.scanFormat = ScanFormat.ALL_FORMATS,
      required this.onBarcodeViewCreated});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Platform not supported'));
  }
}
