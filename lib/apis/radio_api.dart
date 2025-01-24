import 'package:flutter/material.dart';
import 'package:live_radio/models/radio_station_model.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:radio_player/radio_player.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../utils/toast.dart';

class RadioApi {
  static late RadioPlayer player;

  static Future<void> initPlayer(BuildContext context) async {
    final provider = Provider.of<RadioProvider>(context, listen: false);

    player = RadioPlayer();
    await player.stop();
    await player.setChannel(
        title: provider.station.name, url: provider.station.streamURL);

    await player.play();
  }

  static Future<void> changeStation(RadioStation station) async {
    await player.stop();
    await player.setChannel(title: station.name, url: station.streamURL);

    await player.play();

    // bool offline = await isStationOffline(station.streamURL);
    // if (offline) {
    //   // Handle the station being offline
    //   showToast('${station.name} is offline');
    //   await player.stop();

    //   // You can show a message to the user or update the UI accordingly
    // } else {
    //   await player.stop();
    //   await player.setChannel(title: station.name, url: station.streamURL);
    //   await player.play();
    // }
  }

  static Future<bool> isStationOffline(String streamUrl) async {
    try {
      final response = await http.get(Uri.parse(streamUrl));
      if (response.statusCode == 200) {
        return false; // Station is online
      } else {
        return true; // Station is offline
      }
    } catch (e) {
      return true; // Station is offline
    }
  }
}
