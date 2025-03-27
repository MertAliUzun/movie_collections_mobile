import 'package:flutter/material.dart';

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final Alignment alignment;
  final double offsetY;

  CustomFloatingActionButtonLocation({
    required this.alignment,
    this.offsetY = 0,
  });

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset standard = FloatingActionButtonLocation.centerFloat.getOffset(scaffoldGeometry);
    return Offset(standard.dx, standard.dy + offsetY); // 📌 Y ekseninde yukarı kaydır
  }
}
