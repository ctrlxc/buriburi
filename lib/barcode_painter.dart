import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(this.absoluteImageSize, this.barcodeLocations);

  final Size absoluteImageSize;
  final List<Barcode> barcodeLocations;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(Barcode barcode) {
      return Rect.fromLTRB(
        barcode.boundingBox.left * scaleX,
        barcode.boundingBox.top * scaleY,
        barcode.boundingBox.right * scaleX,
        barcode.boundingBox.bottom * scaleY,
      );
    }

    final inner = Paint()..color = Colors.green.withOpacity(0.2);

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.green;

    for (final barcode in barcodeLocations) {
      final r = scaleRect(barcode);
      canvas.drawRect(r, inner);
      canvas.drawRect(r, outer);

      var isRelease = const bool.fromEnvironment('dart.vm.product');

      if (isRelease) {
        continue;
      }

      final t = TextPainter()
        ..text = TextSpan(
          text: barcode.rawValue,
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 8.0,
          ),
        )
        ..textDirection = TextDirection.ltr
        ..layout(
          minWidth: 0,
          maxWidth: size.width,
        );

      t.paint(
          canvas,
          Offset(
            barcode.boundingBox.left * scaleX,
            barcode.boundingBox.bottom * scaleY,
          ));
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.barcodeLocations != barcodeLocations;
  }
}
