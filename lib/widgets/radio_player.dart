import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/apis/shared_prefs_api.dart';
import 'package:live_radio/models/radio_station_model.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:live_radio/utils/radio_stations.dart';
import 'package:live_radio/widgets/radio_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:volume_controller/volume_controller.dart';

class RadioPlayer extends StatefulWidget {
  const RadioPlayer({super.key});

  @override
  State<RadioPlayer> createState() => _RadioPlayerState();
}

class _RadioPlayerState extends State<RadioPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  late Animation<Offset> radioOffset;
  late Animation<Offset> radioListOffset;

  late VolumeController _volumeController;
  late final StreamSubscription<double> _subscription;

  static bool listEnabled = false;
  bool isPlaying = true;
  bool isMuted = false;
  List metadata = [];
  String artists = '';

  late RadioStation selectedStation;
  late RadioProvider provider;

  String _filteredLang = "Tamil";
  String get filteredLang => _filteredLang;
  set filteredLang(String value) {
    setState(() {
      _filteredLang = value;
    });
  }

  double _currentVolume = 0.5;
  double _volumeValue = 0;

  // var stationName = '';
  @override
  void initState() {
    super.initState();

    // final provider = Provider.of<RadioProvider>(context, listen: true);
    // selectedStation = provider.station;

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    radioListOffset = Tween(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeOut));

    radioOffset = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    RadioApi.player.stateStream.listen((event) {
      setState(() {
        isPlaying = event;
      });
    });
    RadioApi.player.metadataStream.listen((value) {
      setState(() {
        artists = '';
        metadata = value;
        for (int i = 0; i < metadata.length - 1; i++) {
          artists += metadata[i] + ', ';
        }
        // [Karthik, MassTamilan.com, Kanimozhiye, MassTamilan.com, &artist=Karthik - MassTamilan.com&album= Irandam Ulagam - MassTamilan.com]
        //&artist=Vijay Prakash%2C Chinmayi Sripada%2C SuVi%2C Vijay - MassTamilan.fm&album=Nanban - MassTamilan.fm
      });
    });

    _volumeController = VolumeController.instance;
    _subscription = _volumeController.addListener((volume) {
      setState(() => _volumeValue = volume);
    }, fetchInitialVolume: true);

    _volumeController.getVolume().then((volume) => _volumeValue = volume);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<RadioProvider>(context, listen: true);
    selectedStation = provider.station;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context, listen: true);
    List<RadioStation> filteredStations = [];
    String stationName = SharedPrefsApi.currentStation;
    String selectedLanguage = filteredLang; // SharedPrefsApi.selectedLanguage;
    filteredStations = RadioStations.allStations
        .where((station) => station.language == selectedLanguage)
        .toList();
    filteredStations.sort((a, b) => a.name.compareTo(b.name));
    int totalStations = filteredStations.length;
    int currentIndex =
        filteredStations.indexWhere((station) => station.name == stationName);

    var _tapPosition;
    void _storePosition(TapDownDetails details) {
      _tapPosition = details.globalPosition;
    }

    final overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) {
      //return 0;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Online FM Radio Player',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                )),
            const SizedBox(height: 20),
            Container(
                height: 200,
                width: 300,
                color: Colors.transparent,
                child:
                    Consumer<RadioProvider>(builder: ((context, value, child) {
                  artists = '';
                  var photoURL = value.station.photoURL == ''
                      ? Image.asset('assets/radio.png',
                          width: 30, height: 30, fit: BoxFit.cover)
                      : Image.asset(value.station.photoURL,
                          width: 50, height: 50, fit: BoxFit.contain);
                  // stationName = value.station.name; // RadioProvider.getRadioStation(value.station);
                  return photoURL;
                }))),
            const SizedBox(height: 20),
            Text(
              provider.station.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // show artists info in scrolling text
            Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: TextScroll(
                  //scroll the artists info
                  artists,
                  velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                  delayBefore: const Duration(milliseconds: 500),
                  // numberOfReps: 5,
                  pauseBetween: const Duration(milliseconds: 50),
                  style: const TextStyle(color: Colors.white),
                  selectable: true,
                  // overflow: TextOverflow.ellipsis,
                )),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // List Icon
              IconButton(
                onPressed: () {
                  setState(() {
                    listEnabled = !listEnabled;
                  });
                  switch (animationController.status) {
                    case AnimationStatus.dismissed:
                      animationController.forward();
                      break;
                    case AnimationStatus.completed:
                      animationController.reverse();
                      break;
                    default:
                  }
                },
                color: listEnabled ? Colors.amber : Colors.white,
                iconSize: 20,
                icon: const Icon(Icons.list),
              ),
              //previous icon
              IconButton(
                onPressed: () async {
                  RadioStation previousStation =
                      filteredStations[(currentIndex - 1) % totalStations];
                  provider.setRadioStation(previousStation);
                  SharedPrefsApi.setStation(previousStation);
                  SharedPrefsApi.currentStation = previousStation.name;
                  await RadioApi.changeStation(previousStation);

                  setState(() {
                    selectedStation = previousStation;
                  });
                },
                color: Colors.white,
                iconSize: 20,
                tooltip: 'Previous Station',
                icon: const Icon(Icons.skip_previous),
              ),
              // Play / Pause icon
              IconButton(
                onPressed: () async {
                  artists = '';
                  // RadioApi.player.setChannel(title: title, url: url)
                  isPlaying ? RadioApi.player.stop() : RadioApi.player.play();
                },
                color: Colors.white,
                iconSize: 20,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              // Next icon
              IconButton(
                onPressed: () async {
                  RadioStation nextStation =
                      filteredStations[(currentIndex + 1) % totalStations];
                  provider.setRadioStation(nextStation);
                  SharedPrefsApi.setStation(nextStation);
                  SharedPrefsApi.currentStation = nextStation.name;
                  await RadioApi.changeStation(nextStation);

                  setState(() {
                    selectedStation = nextStation;
                  });
                },
                color: Colors.white,
                iconSize: 20,
                tooltip: 'Next Station',
                icon: const Icon(Icons.skip_next),
              ),
              // Volume icon
              IconButton(
                onPressed: () async {
                  _volumeController.showSystemUI =
                      true; // always show the system volume UI
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
              )
            ]),
            Row(
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
                ),
              ],
            ),
          ],
        )),
        // Radio List
        SlideTransition(
          position: radioListOffset,
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                  20,
                ))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Radio List',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => {
                          showMenu(
                              context: context,
                              position: RelativeRect.fromRect(
                                  _tapPosition! &
                                      const Size(40,
                                          40), // smaller rect, the touch area
                                  Offset.zero & overlay!.semanticBounds.size),
                              items: <PopupMenuEntry>[
                                const PopupMenuItem(
                                    value: 'Tamil',
                                    child: Row(
                                      children: [
                                        Text('Tamil'),
                                      ],
                                    )),
                                const PopupMenuItem(
                                    value: 'Hindi',
                                    child: Row(
                                      children: [
                                        Text('Hindi'),
                                      ],
                                    )),
                                const PopupMenuItem(
                                    value: 'English',
                                    child: Row(
                                      children: [
                                        Text('English'),
                                      ],
                                    ))
                              ]).then((value) {
                            filteredLang = value;
                          })
                        },
                        onTapDown: _storePosition,
                        child: const Icon(
                          Icons.filter_alt,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  color: Colors.black,
                  indent: 20,
                  endIndent: 20,
                ),
                Expanded(
                    child: RadioList(
                  language: filteredLang,
                )) //
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            backgroundBlendMode: BlendMode.clear,
            color: Colors.black,
          ),
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextScroll(
                  //scroll the artists info
                  'Online FM Radio Player By Kumar',
                  mode: TextScrollMode.bouncing,
                  velocity: Velocity(pixelsPerSecond: Offset(25, 0)),
                  delayBefore: Duration(milliseconds: 500),
                  // numberOfReps: 5,
                  pauseBetween: Duration(milliseconds: 50),
                  style: TextStyle(
                    backgroundColor: Colors.black,
                    color: Colors.white,
                  ),
                  selectable: true,
                  // overflow: TextOverflow.ellipsis,
                ),
              ]),
        ),
      ],
    );
  }
}
