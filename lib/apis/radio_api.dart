import 'package:flutter/material.dart';
import 'package:live_radio/models/radio_station_model.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:radio_player/radio_player.dart';
import 'package:provider/provider.dart';

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
    print(station.name);
    print(station.streamURL);
    await player.setChannel(title: station.name, url: station.streamURL);

    await player.play();
  }
}
