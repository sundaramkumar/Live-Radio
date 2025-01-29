import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:volume_controller/volume_controller.dart';
import '../providers/radio_provider.dart';

class CurrentStationPage extends StatefulWidget {
  @override
  State<CurrentStationPage> createState() => _CurrentStationPageState();
}

class _CurrentStationPageState extends State<CurrentStationPage> {
  late VolumeController _volumeController;

  double _currentVolume = 0.5;
  double _volumeValue = 0;
  bool isPlaying = true;
  bool isMuted = false;
  String artists = '';

  late final StreamSubscription<double> _subscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    RadioApi.player.stateStream.listen((event) {
      setState(() {
        isPlaying = event;
      });
    });

    _volumeController = VolumeController.instance;
    _subscription = _volumeController.addListener((volume) {
      setState(() => _volumeValue = volume);
    }, fetchInitialVolume: true);

    _volumeController.getVolume().then((volume) => _volumeValue = volume);
  }

  @override
  void dispose() {
    _subscription.cancel();
    // subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context);
    final station = provider.station;
    var photoURL = station.photoURL == ''
        ? Image.asset('assets/radio.png',
            width: 100, height: 100, fit: BoxFit.fill)
        : Image.asset(station.photoURL,
            width: 100, height: 100, fit: BoxFit.fill);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
          toolbarHeight: 75,
          title: const Text(''),
          // backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          actions: [
            Image.asset('assets/radio.png', width: 40),
          ]),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/framebg.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Playing Now",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              photoURL,
              const SizedBox(height: 20),
              Text(
                station.name,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                station.language,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Image.network(station.photoURL),

              _buildPlayPauseIconButton(),
              const SizedBox(height: 20),
              _buildVolumeSlider(),
              const SizedBox(height: 20),
              TextScroll(
                'Stream URL: ${station.streamURL}',
                style: const TextStyle(fontSize: 14, color: Colors.white),
                velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                delayBefore: const Duration(milliseconds: 500),
                pauseBetween: const Duration(milliseconds: 50),
                fadeBorderSide: FadeBorderSide.both,
                selectable: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconButton _buildPlayPauseIconButton() {
    return IconButton(
      onPressed: () async {
        artists = '';
        isPlaying ? RadioApi.player.stop() : RadioApi.player.play();
      },
      color: Colors.white,
      iconSize: 20,
      icon: Image.asset(isPlaying ? 'assets/pause.png' : 'assets/play.png'),
    );
  }

  Widget _buildVolumeSlider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _volumeValue,
          onChanged: (value) {
            _volumeController.showSystemUI = false;
            _volumeController.setVolume(value);
          },
          min: 0,
          max: 1,
          divisions: 10,
          activeColor: Colors.pink,
          inactiveColor: Colors.white24,
        ),
        _buildVolumeIconButton(),
      ],
    );
  }

  IconButton _buildVolumeIconButton() {
    return IconButton(
      onPressed: () async {
        _volumeController.showSystemUI = true;
        isMuted
            ? _volumeController.setVolume(0.5)
            : _volumeController.muteVolume();
        setState(() {
          isMuted = !isMuted;
        });
      },
      color: Colors.white,
      iconSize: 20,
      icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
    );
  }
}
