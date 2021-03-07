import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'barcode_painter.dart';
import 'scanner_utils.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  List<Barcode>? _scanResults;
  CameraController? _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final description = await ScannerUtils.getCamera(_direction);

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );

    await _camera!.initialize();

    await _camera!.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;

      ScannerUtils.detect(
        image: image,
        detectInImage: _barcodeDetector.detectInImage,
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          setState(() {
            _scanResults = results;
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  // bool validateResult(dynamic results) {
  //   if (results == null ||
  //       !results is List<Barcode> ||
  //       (results as List<Barcode>).isEmpty) {
  //     return false;
  //   }

  //   return true;
  // }

  Widget _buildResults() {
    if (_scanResults == null ||
        _scanResults!.isEmpty ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return Center(
        child: Text(
          'QRコードをカメラにかざしてください',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 14,
          ),
        ),
      );
    }

    final imageSize = Size(
      _camera!.value.previewSize.height,
      _camera!.value.previewSize.width,
    );

    return CustomPaint(
      painter: BarcodeDetectorPainter(imageSize, _scanResults!),
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
              child: Text(
                'カメラをきどうちゅう...',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  Future<void> _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera?.stopImageStream();
    await _camera?.dispose();

    setState(() {
      _camera = null;
    });

    await _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('もらう？'),
        actions: <Widget>[],
      ),
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }

  @override
  void dispose() {
    _camera?.dispose().then((_) {
      _barcodeDetector.close();
    });

    super.dispose();
  }
}
