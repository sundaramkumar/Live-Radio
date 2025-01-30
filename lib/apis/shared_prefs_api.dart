import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import '../models/radio_station_model.dart';
import '../utils/radio_stations.dart';

class SharedPrefsApi {
  static const _key = 'radio_station';
  static const _favouriteKey = 'favourite';
  static const _currentStationKey = 'currentStation';
  static const _filterKey = 'filter';
  static String currentStation = '';
  static String selectedLanguage = 'Tamil';
  static String selectedFilter = 'Favourites';

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

    if (!favouritesList.contains(station.name)) {
      favouritesList.add(station.name);
      sharedPrefs.setStringList(_favouriteKey, favouritesList);
    }
  }

  static Future<void> removeFavourite(RadioStation station) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    List<String> favouritesList = [];
    favouritesList =
        sharedPrefs.getStringList(_favouriteKey) ?? []; // as List<String>;
    // if (favouritesList.length > 1) {
    if (favouritesList.contains(station.name)) {
      favouritesList.remove(station.name);
      sharedPrefs.setStringList(_favouriteKey, favouritesList);
    }
    // }
  }

  static Future<List<String>> getFavourites() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    List<String> favouritesList = [];
    favouritesList = sharedPrefs.getStringList(_favouriteKey) ?? [];
    return favouritesList;
  }

  static Future<void> setFilter(String filterName) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    selectedFilter = filterName;
    sharedPrefs.setString(_filterKey, filterName);
  }

  static Future<String> getFilter() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    return sharedPrefs.getString(_filterKey).toString();
  }
}
