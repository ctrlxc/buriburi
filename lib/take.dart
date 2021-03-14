import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:buriburi/payment.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:file_picker/file_picker.dart';

import 'barcode_painter.dart';
import 'barcode_scanner_utils.dart';

class Take extends StatefulWidget {
  const Take({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TakeState();
}

class _TakeState extends State<Take> {
  Size? _imageSize;
  List<Barcode>? _scanResults;

  CameraController? _camera;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  File? _pickedImage;

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
      ).then((dynamic results) {
        if (!mounted) return;

        setState(() {
          _imageSize = Size(
            _camera!.value.previewSize!.height,
            _camera!.value.previewSize!.width,
          );

          _scanResults = results;
        });

        gotoTookIfValid(results);
      }).whenComplete(() {
        _isDetecting = false;
      });
    });
  }

  Payment? _validBarcode(List<Barcode>? barcodes) {
    if (barcodes == null || barcodes.isEmpty) {
      return null;
    }

    for (final barcode in barcodes) {
      final payment = Payment.fromJson(json.decode(barcode.rawValue));

      if (payment.date != null && payment.money != null) {
        return payment;
      }
    }

    return null;
  }

  Future<bool> gotoTookIfValid(List<Barcode>? barcodes) async {
    final payment = _validBarcode(barcodes);

    if (payment == null) {
      return false;
    }

    if (_camera != null) {
      await _camera!.stopImageStream();
    }

    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacementNamed('/took', arguments: payment);
    });

    return true;
  }

  Future<void> _initializeTorch() async {
    _torch = TorchController();
    _torch!.initialize();
  }

  Widget _buildResults() {
    if (_pickedImage != null &&
        _imageSize != null &&
        _scanResults != null &&
        _scanResults!.isNotEmpty) {
      return Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.file(_pickedImage!).image,
            fit: BoxFit.fill,
          ),
        ),
        child: CustomPaint(
          painter: BarcodeDetectorPainter(_imageSize!, _scanResults!),
        ),
      );
    }

    if (_camera == null) {
      return Container();
    }

    if (_imageSize == null || _scanResults == null || _scanResults!.isEmpty) {
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

    return CustomPaint(
      painter: BarcodeDetectorPainter(_imageSize!, _scanResults!),
    );
  }

  Widget _buildCamera() {
    if (_camera == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return CameraPreview(_camera);
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            color: Colors.black,
          ),
          _buildCamera(),
          _buildResults(),
        ],
      ),
    );
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
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _image,
            child: const Icon(Icons.image),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          FloatingActionButton(
            onPressed: _toggleTorch,
            child: _isTorchOn
                ? const Icon(Icons.flash_off)
                : const Icon(Icons.flash_on),
          ),
        ],
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

  Future _image() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    // cancel
    if (result == null) {
      return;
    }

    final file = File(result.files.single.path);

    final imageSize = await _getImageSize(file);
    final results = await _scanBarcode(file);

    setState(() {
      _pickedImage = file;
      _imageSize = imageSize;
      _scanResults = results;
    });

    final isValid = await gotoTookIfValid(results);

    if (!isValid) {
      // TODO show error

      setState(() {
        _pickedImage = null;
        _imageSize = null;
        _scanResults = null;
      });
    }
  }

  Future<Size> _getImageSize(File imageFile) {
    final completer = Completer<Size>();

    final image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    return completer.future;
  }

  Future<dynamic> _scanBarcode(File imageFile) async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    return _barcodeDetector.detectInImage(visionImage);
  }
}
