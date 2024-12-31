import 'package:flutter/material.dart';
import 'package:live_radio/models/radio_station_model.dart';

class RadioProvider with ChangeNotifier {
  final RadioStation initialRadioStation;
  // final RadioStation initialRadioStationName;

  RadioProvider(this.initialRadioStation);

  RadioStation? _station;
  // String? _stationName;

  RadioStation get station => _station ?? initialRadioStation;

  void setRadioStation(RadioStation station) {
    _station = station;
    // _stationName = station.name;
    notifyListeners();
  }
}
