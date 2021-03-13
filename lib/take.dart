import 'dart:convert';

import 'package:buriburi/payment.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';

import 'barcode_painter.dart';
import 'barcode_scanner_utils.dart';

class Take extends StatefulWidget {
  const Take({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TakeState();
}

class _TakeState extends State<Take> {
  List<Barcode>? _scanResults;
  CameraController? _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  TorchController? _torch;
  bool _isTorchOn = false;

  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTorch();
  }

  Future<void> _initializeCamera() async {
    final description = await BarcodeScannerUtils.getCamera(_direction);

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

      BarcodeScannerUtils.detect(
        image: image,
        detectInImage: _barcodeDetector.detectInImage,
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          if (!mounted) return;

          setState(() {
            _scanResults = results;
          });
        },
      ).then((_) {
        if (_scanResults != null && _scanResults!.isNotEmpty) {
          // @@@ need validation

          _camera!.stopImageStream().then((_) {
            final payment =
                Payment.fromJson(json.decode(_scanResults![0].rawValue));

            Navigator.of(context)
                .pushReplacementNamed('/took', arguments: payment);
          });
        }
      }).whenComplete(() {
        _isDetecting = false;
      });
    });
  }

  Future<void> _initializeTorch() async {
    _torch = TorchController();
    _torch!.initialize();
  }

  Widget _buildResults() {
    if (_camera == null ||
        !_camera!.value.isInitialized ||
        _scanResults == null ||
        _scanResults!.isEmpty) {
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
              child: CircularProgressIndicator(),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  color: Colors.black,
                ),
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

  Future<void> _toggleTorch() async {
    setState(() {
      _torch?.toggle().then((on) {
        _isTorchOn = on;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('もらう？'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTorch,
        child: _isTorchOn
            ? const Icon(Icons.flash_off)
            : const Icon(Icons.flash_on),
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
