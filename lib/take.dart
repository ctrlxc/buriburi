import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Take extends StatefulWidget {
  @override
  TakeState createState() => TakeState();
}

class TakeState extends State<Take> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;

  final _barcodeDetector = FirebaseVision.instance.barcodeDetector();

  // bool _shouldSkipScanning;
  String _scaned = "scaned";

  @override
  void initState() {
    super.initState();

    availableCameras().then((value) {
      if (value.isEmpty) {
        showAlertDialog("カメラがみつかりません").then((_) {
          Navigator.pop(context);
        });

        return;
      }

      _cameras = value;
      _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
      _cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }

        setState(() {});

        scanQr();
      });
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   // App state changed before we got the chance to initialize.
  //   if (_cameraController == null || !_cameraController.value.isInitialized) {
  //     return;
  //   }
  //   if (state == AppLifecycleState.inactive) {
  //     _cameraController?.dispose();
  //   } else if (state == AppLifecycleState.resumed) {
  //     if (_cameraController != null) {
  //       onNewCameraSelected(_cameraController.description);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Widget? body;

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      body = Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio,
                child: CameraPreview(
                  _cameraController,
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  FittedBox(
                    child: Text(
                      _scaned,
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      body = Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('もらう？'),
      ),
      body: body,
    );
  }

  Future<void> scanQr() async {
    var _isScanBusy = false;
    _cameraController!.startImageStream((image) async {
      if (_isScanBusy) {
        // print("busy");
        return;
      }

      _isScanBusy = true;

      final scan = _barcodeDetector.detectInImage(
        FirebaseVisionImage.fromBytes(
          image.planes.first.bytes,
          buildMetadata(image),
        ),
      );

      scan.then((barcodes) {
        if (barcodes.isNotEmpty) {
          setState(() {
            _scaned = barcodes.first.rawValue;
          });
        }

        _isScanBusy = false;
      });
    });
  }

  FirebaseVisionImageMetadata buildMetadata(CameraImage image) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      rotation: ImageRotation.rotation270,
      planeData: image.planes.map(
        (plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          // title: Text("タイトル"),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
