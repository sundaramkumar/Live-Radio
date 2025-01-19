import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import '../models/radio_station_model.dart';
import '../utils/radio_stations.dart';

class SharedPrefsApi {
  static const _key = 'radio_station';
  static const _favouriteKey = 'favourite';
  static const _currentStationKey = 'currentStation';
  static String currentStation = '';
  static String selectedLanguage = 'Tamil';

  static Future<RadioStation> getInitialRadioStation() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final stationName = await sharedPrefs.getString(_key);

    if (stationName == null) {
      currentStation = RadioStations.allStations[0].name;
      sharedPrefs.setString(
          _currentStationKey, RadioStations.allStations[0].name);
      return RadioStations.allStations[0];
    }
    try {
      currentStation = RadioStations.allStations
          .firstWhere((element) => element.name == stationName)
          .name;
      sharedPrefs.setString(
          _currentStationKey,
          RadioStations.allStations
              .firstWhere((element) => element.name == stationName)
              .name);
      return RadioStations.allStations
          .firstWhere((element) => element.name == stationName);
    } catch (e) {
      print(e.toString());
    }
    currentStation = RadioStations.allStations[0].name;
    sharedPrefs.setString(
        _currentStationKey, RadioStations.allStations[0].name);
    return RadioStations.allStations[0];
  }

  static Future<void> setStation(RadioStation station) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final stationName = sharedPrefs.setString(_key, station.name);
    currentStation = station.name;
  }

  static Future<String?> getCurrentStation() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    // print(sharedPrefs.getString(_currentStationKey));
    return sharedPrefs.getString(_currentStationKey);
  }

  static Future<void> setFavourites(RadioStation station) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    List<String> favouritesList = [];
    favouritesList =
        sharedPrefs.getStringList(_favouriteKey) ?? []; // as List<String>;
    // if (favouritesList.isEmpty) {
    //   favouritesList.add(station.name);
    //   sharedPrefs.setStringList(_favouriteKey, favouritesList);
    // } else {
    favouritesList.add(station.name);
    sharedPrefs.setStringList(_favouriteKey, favouritesList);
    // }
    // List<String> value = [...favouritesList, station.name];

    print('favouritesList is $favouritesList');
    print(favouritesList);
  }

  static Future<void> setLanguage(String language) async {
    selectedLanguage = language;
    // print('selectedLanguage is $selectedLanguage');
  }
}
