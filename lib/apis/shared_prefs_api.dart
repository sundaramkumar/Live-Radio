import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station_model.dart';
import '../utils/radio_stations.dart';

class SharedPrefsApi {
  static const _key = 'radio_station';
  static Future<RadioStation> getInitialRadioStation() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final stationName = await sharedPrefs.getString(_key);

    if (stationName == null) return RadioStations.allStations[0];
    return RadioStations.allStations
        .firstWhere((element) => element.name == stationName);
  }

  static Future<void> setStation(RadioStation station) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final stationName = sharedPrefs.setString(_key, station.name);
  }
}
