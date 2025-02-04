import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/apis/shared_prefs_api.dart';
import 'package:live_radio/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:volume_controller/volume_controller.dart';
import '../providers/radio_provider.dart';
import '../providers/volume.provider.dart';

class CurrentStationPage extends StatefulWidget {
  @override
  State<CurrentStationPage> createState() => _CurrentStationPageState();
}

class _CurrentStationPageState extends State<CurrentStationPage> {
  late VolumeController _volumeController;
  late List<String> favouritesList = [];
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
    _loadFavourites();
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

  Future<void> _loadFavourites() async {
    // favouritesList = await SharedPrefsApi.getFavourites();
    SharedPrefsApi.getFavourites().then((favourites) {
      favouritesList = favourites;
      print('favouritesList ---> : $favouritesList');
    });
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
              Text(
                "Playing Now",
                style: GoogleFonts.aclonica(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              photoURL,
              const SizedBox(height: 20),
              Text(
                station.name,
                style:
                    GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                station.language,
                style:
                    GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Image.network(station.photoURL),

              _buildPlayPauseIconButton(),
              const SizedBox(height: 20),
              _buildVolumeSlider(),
              const SizedBox(height: 20),
              _buildFavouritesSection(context, station),
              const SizedBox(height: 20),
              _buildFooter(),
              // if you want to display the stream URL
              // TextScroll(
              //   'Stream URL: ${station.streamURL}',
              //   style: const TextStyle(fontSize: 14, color: Colors.white),
              //   velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
              //   delayBefore: const Duration(milliseconds: 500),
              //   pauseBetween: const Duration(milliseconds: 50),
              //   fadeBorderSide: FadeBorderSide.both,
              //   selectable: true,
              // ),
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
        Consumer<VolumeProvider>(
          builder: (context, volumeProvider, child) {
            return Row(
              children: [
                Text(
                  '${(volumeProvider.volume * 100).round()}%',
                  style:
                      GoogleFonts.montserrat(fontSize: 16, color: Colors.white),
                ),
                Slider(
                  value: volumeProvider.volume,
                  min: 0,
                  max: 1,
                  activeColor: Colors.pink,
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    volumeProvider.setVolume(value);
                    _volumeController.showSystemUI = false;
                    _volumeController.setVolume(value);
                  },
                ),
              ],
            );
          },
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
      color: isMuted ? Colors.red : Colors.white,
      iconSize: 20,
      icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
    );
  }

  Widget _buildFavouritesSection(BuildContext context, station) {
    if (favouritesList.contains(station.name)) {
      return TextButton(
          onPressed: () {
            setState(() {
              SharedPrefsApi.removeFavourite(station);
              favouritesList.remove(station.name);
            });
            showToast('Removed From Favourites');
          },
          child: const Text(
            'Remove From Favourites',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ));
    } else {
      return TextButton(
          onPressed: () {
            setState(() {
              SharedPrefsApi.setFavourites(station);
              favouritesList.add(station.name);
            });
            showToast('Added to Favourites');
          },
          child: const Text(
            'Add to Favourites',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ));
    }
  }

  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(
        backgroundBlendMode: BlendMode.clear,
        color: Colors.black,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        TextScroll(
          'Live Radio Player By Kumar Sundaram',
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
          delayBefore: const Duration(milliseconds: 500),
          pauseBetween: const Duration(milliseconds: 50),
          style: GoogleFonts.montserrat(fontSize: 14).copyWith(
            backgroundColor: Colors.black,
            color: Colors.white,
          ),
          selectable: true,
        ),
      ]),
    );
  }
}
