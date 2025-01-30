import 'package:flutter/material.dart';

class VolumeProvider with ChangeNotifier {
  double _volume = 0.5;

  double get volume => _volume;

  void setVolume(double volume) {
    _volume = volume;
    notifyListeners();
  }
}
