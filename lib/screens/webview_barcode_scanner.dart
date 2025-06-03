import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner_plus/constant.dart';
import 'package:simple_barcode_scanner_plus/enum.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../barcode_appbar.dart';

class WebviewBarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final CameraFace cameraFace;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
  final BarcodeAppBar? barcodeAppBar;
  final int? delayMillis;
  final Function? onClose;

  const WebviewBarcodeScanner({
    super.key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    this.cameraFace = CameraFace.back,
    required this.onScanned,
    this.appBarTitle,
    this.centerTitle,
    this.barcodeAppBar,
    this.delayMillis,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    WebViewController controller = WebViewController();
    bool isPermissionGranted = false;

    _checkCameraPermission().then((granted) {
      debugPrint("Permission is $granted");
      isPermissionGranted = granted;
    });

    return FutureBuilder<bool>(
        future: initPlatformState(
          controller: controller,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return WebViewWidget(
              controller: controller,
              //permissionRequested: (url, permissionKind, isUserInitiated) =>
              //     _onPermissionRequested(
              //   url: url,
              //   kind: permissionKind,
              //   isUserInitiated: isUserInitiated,
              //   context: context,
              //   isPermissionGranted: isPermissionGranted,

              // ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  /// Checks if camera permission has already been granted
  Future<bool> _checkCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  String getAssetFileUrl({required String asset}) {
    final assetsDirectory = p.join(p.dirname(Platform.resolvedExecutable),
        'data', 'flutter_assets', asset);
    return Uri.file(assetsDirectory).toString();
  }

  Future<bool> initPlatformState(
      {required WebViewController controller}) async {
    String? barcodeNumber;

    try {
      await controller.loadFlutterAsset(
          getAssetFileUrl(asset: PackageConstant.barcodeFilePath));

      /// Listen to web to receive barcode
      // controller.webMessage.listen((event) {
      //   if (event['methodName'] == "successCallback") {
      //     if (event['data'] is String &&
      //         event['data'].isNotEmpty &&
      //         barcodeNumber == null) {
      //       barcodeNumber = event['data'];
      //       onScanned(barcodeNumber!);
      //     }
      //   }
      // });

      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      await controller.addJavaScriptChannel('MessageInvoker',
          onMessageReceived: (JavaScriptMessage message) {
        final event = jsonDecode(message.message);
        final methodName = event['methodName'];
        final data = event['data'];

        if (methodName == "successCallback" &&
            data is String &&
            data.isNotEmpty) {
          barcodeNumber ??= data;
          if (barcodeNumber != null) {
            onScanned(barcodeNumber!);
          }
        }
      });
    } catch (e) {
      rethrow;
    }
    return true;
  }
}
