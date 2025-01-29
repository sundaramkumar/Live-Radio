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
import '../utils/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  StreamSubscription<List<ConnectivityResult>>? subscription;

  //Connection status check result.
  ConnectivityResult? connectivityResult;

  static bool listEnabled = false;
  bool isPlaying = true;
  bool isMuted = false;
  List metadata = [];
  String artists = '';

  late RadioStation selectedStation;
  late RadioProvider provider;

  String _filteredLang = "Tamil";
  String _isFavourites = "N";
  late List<String> favouritesList = [];
  Future<Image?>? artworkImage;
  String get filteredLang => _filteredLang;
  String get isFavourites => _isFavourites;
  set filteredLang(String value) {
    setState(() {
      _filteredLang = value;
      _isFavourites = "N";
    });
  }

  set isFavourites(String value) {
    setState(() {
      _filteredLang = filteredLang;
      _isFavourites = value;
    });
  }

  double _currentVolume = 0.5;
  double _volumeValue = 0;

  var _tapPosition;
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  // var stationName = '';
  @override
  void initState() {
    super.initState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        connectivityResult = result.isNotEmpty ? result.first : null;
      });

      if (connectivityResult == ConnectivityResult.none) {
        showToast('You seem to be offline');
      } else {
        showToast('You seem to be online now');
      }
    });
    _loadFavourites();

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
    artworkImage = RadioApi.player.getArtworkImage();
    RadioApi.player.metadataStream.listen((value) {
      setState(() {
        artists = '';
        metadata = value;
        for (int i = 0; i < metadata.length - 1; i++) {
          artists += metadata[i] + ', ';
        }
        // sample artists info
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
    // subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context, listen: true);
    List<RadioStation> filteredStations = _getFilteredStations();
    int totalStations = filteredStations.length;
    int currentIndex = _getCurrentStationIndex(filteredStations);

    // Check if the selected station is offline
    // checkStationStatus(provider.station);

    final overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) {
      //return 0;
    }
    return Padding(
      padding: const EdgeInsets.all(0.0), //(left: 0, right: 16.0),
      child: Row(
        children: [
          Container(
            width: 60, // Small sidebar width
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset("assets/radio.png", width: 40),
                ),
                const SizedBox(height: 50),
                menuText("Favourites", "Favourites", isSelected: true),
                const SizedBox(height: 20),
                menuText("Devotional", "Devotional"),
                const SizedBox(height: 20),
                menuText("English", "English"),
                const SizedBox(height: 20),
                menuText("Hindi", "Hindi"),
                const SizedBox(height: 20),
                menuText("Tamil", "Tamil"),

                // isSelected: true), // Selected item highlighted
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 60,
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Column(
                children: [
                  const Text('Popular',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                      child: RadioList(
                    language: filteredLang,
                    favourites: isFavourites,
                  )
                      // child: GridView.count(
                      //   crossAxisCount: 2,
                      //   crossAxisSpacing: 10,
                      //   mainAxisSpacing: 10,
                      //   children: [
                      //     radioStationCard('90.5', 'Divelement', isPlaying: true),
                      //     radioStationCard('94.3', 'Diegodeveloper'),
                      //     radioStationCard('98.5', 'Brayan'),
                      //     radioStationCard('91.0', 'Argel'),
                      //     radioStationCard('104.2', 'Fluttter'),
                      //     radioStationCard('92.7', 'Miau Miua'),
                      //     radioStationCard('92.7', 'Miau Miua'),
                      //     radioStationCard('92.7', 'Miau Miua'),
                      //     radioStationCard('92.7', 'Miau Miua'),
                      //   ],
                      // ),
                      ),
                  const SizedBox(height: 10),
                  _buildControlButtons(
                      filteredStations, currentIndex, totalStations, provider),
                  _buildVolumeSlider(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Expanded(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           _buildHeader(),
    //           const SizedBox(height: 10),
    //           _buildStationImage(provider),
    //           const SizedBox(height: 10),
    //           _buildStationName(provider),
    //           const SizedBox(height: 15),
    //           _buildScrollingArtistsInfo(),
    //           const SizedBox(height: 15),
    //           _buildControlButtons(
    //               filteredStations, currentIndex, totalStations, provider),
    //           _buildVolumeSlider(),
    //         ],
    //       ),
    //     ),
    //     _buildRadioList(context, _tapPosition, overlay),
    //     _buildFooter(),
    //   ],
    // );
  }

  Widget radioStationCard(BuildContext context, RadioStation station,
      bool isSelected, Image photoURL) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1), // add this line
          color: isSelected ? Colors.pinkAccent : Color(0x0032324E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                provider.setRadioStation(station);
                SharedPrefsApi.setStation(station);
                SharedPrefsApi.currentStation = station.name;
                // print(SharedPrefsApi.filterStations('English'));
                await RadioApi.changeStation(station);
                setState(() {
                  selectedStation = station;
                });
              },
              child: Container(
                child: photoURL,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget playbackControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Image.asset('assets/left.png'),
                // icon: Icon(Icons.arrow_left, size: 40, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon: Image.asset('assets/play.png'),
                // icon: Icon(Icons.arrow_left, size: 40, color: Colors.white),
                onPressed: () {}),
            // Container(
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Colors.pink,
            //   ),
            //   padding: EdgeInsets.all(16),
            //   child: Image.asset('assets/play.png'),
            //   // Icon(Icons.play_arrow, color: Colors.white, size: 40),
            // ),
            IconButton(
                icon: Image.asset('assets/right.png'),
                // icon: Icon(Icons.arrow_right, size: 40, color: Colors.white),
                onPressed: () {}),
          ],
        ),
        _buildVolumeSlider(),
        // Slider(
        //   value: 0.65,
        //   onChanged: (value) {},
        //   activeColor: Colors.pink,
        //   inactiveColor: Colors.white24,
        // ),
      ],
    );
  }

  Future<void> _loadFavourites() async {
    // favouritesList = await SharedPrefsApi.getFavourites();
    SharedPrefsApi.getFavourites().then((favourites) {
      favouritesList = favourites;
    });
  }

  void checkStationStatus(RadioStation station) async {
    bool offline = await isStationOffline(station.streamURL);
    if (offline) {
      setState(() {
        // Handle the station being offline
        // For example, show a message or update the UI
        print('${station.name} seems offline');
        showToast('${station.name} seems offline');
      });
    } else {
      setState(() {
        // Handle the station being online
        print('${station.name} seems online');
        showToast('${station.name} seems online');
      });
    }
  }

  List<RadioStation> _getFilteredStations() {
    if (isFavourites == 'Y') {
      // if favourites is selected, show only the favourite stations
      List<RadioStation> filteredStations = RadioStations.allStations
          .where((station) => favouritesList.contains(station.name))
          .toList();
      filteredStations.sort((a, b) => a.name.compareTo(b.name));
      return filteredStations;
    } else {
      // String stationName = SharedPrefsApi.currentStation;
      String selectedLanguage = filteredLang;
      List<RadioStation> filteredStations = RadioStations.allStations
          .where((station) => station.language == selectedLanguage)
          .toList();
      filteredStations.sort((a, b) => a.name.compareTo(b.name));
      return filteredStations;
    }
  }

  int _getCurrentStationIndex(List<RadioStation> filteredStations) {
    String stationName = SharedPrefsApi.currentStation;
    return filteredStations
        .indexWhere((station) => station.name == stationName);
  }

  Widget _buildHeader() {
    return const Text('Online FM Radio Player',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ));
  }

  Widget _buildStationImage(RadioProvider provider) {
    return Container(
      height: 200,
      width: 300,
      color: Colors.transparent,
      child: Consumer<RadioProvider>(builder: ((context, value, child) {
        artists = '';
        var photoURL = value.station.photoURL == ''
            ? Image.asset('assets/radio.png',
                width: 30, height: 30, fit: BoxFit.cover)
            : Image.asset(value.station.photoURL,
                cacheWidth: 150,
                cacheHeight: 150,
                width: 50,
                height: 50,
                fit: BoxFit.contain);
        return photoURL;
      })),
    );
  }

  Widget _buildStationArtwork() {
    return Container(
      height: 200,
      width: 300,
      color: Colors.transparent,
      child: FutureBuilder(
        future: RadioApi.player.getArtworkImage(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Image artwork;
          if (snapshot.hasData) {
            artwork = snapshot.data;
          } else {
            artwork = Image.asset(
              'assets/radio.png',
              fit: BoxFit.cover,
            );
          }
          return Container(
            height: 180,
            width: 180,
            child: ClipRRect(
              child: artwork,
              borderRadius: BorderRadius.circular(10.0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStationName(RadioProvider provider) {
    return Text(
      provider.station.name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildScrollingArtistsInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: TextScroll(
        artists,
        velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
        delayBefore: const Duration(milliseconds: 500),
        pauseBetween: const Duration(milliseconds: 50),
        style: const TextStyle(color: Colors.white),
        selectable: true,
      ),
    );
  }

  Widget _buildControlButtons(List<RadioStation> filteredStations,
      int currentIndex, int totalStations, RadioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // _buildListIconButton(),
        _buildPreviousIconButton(
            filteredStations, currentIndex, totalStations, provider),
        _buildPlayPauseIconButton(),
        _buildNextIconButton(
            filteredStations, currentIndex, totalStations, provider),
        // _buildVolumeIconButton(),
        // _buildOnlineOfflineIcon(),
      ],
    );
  }

  IconButton _buildListIconButton() {
    return IconButton(
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
    );
  }

  IconButton _buildPreviousIconButton(List<RadioStation> filteredStations,
      int currentIndex, int totalStations, RadioProvider provider) {
    return IconButton(
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
      icon: Image.asset('assets/left.png'),
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

  IconButton _buildNextIconButton(List<RadioStation> filteredStations,
      int currentIndex, int totalStations, RadioProvider provider) {
    return IconButton(
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
      icon: Image.asset('assets/right.png'),
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

  Widget _buildOnlineOfflineIcon() {
    return Column(
      children: [
        Image.asset(
            connectivityResult == ConnectivityResult.none
                ? 'assets/offline.png'
                : 'assets/online.png',
            width: 20,
            height: 20,
            color: Colors.white,
            fit: BoxFit.cover),
        Text(
          connectivityResult == ConnectivityResult.none ? 'Offline' : 'Online',
          style: const TextStyle(fontSize: 7, color: Colors.white),
        )
      ],
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

  Widget _buildRadioList(BuildContext context, var _tapPosition, var overlay) {
    return SlideTransition(
      position: radioListOffset,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10, top: 20),
              child: Row(
                // mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Radio List',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTapDown: (details) {
                      _storePosition(details);
                      _showMenu(context, details.globalPosition);
                    },
                    child: const Icon(
                      Icons.filter_alt,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    isFavourites == 'Y' ? 'Favourites' : filteredLang,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.black,
              indent: 5,
              endIndent: 5,
              thickness: 1,
              height: 5,
            ),
            Expanded(
                flex: 1,
                child: RadioList(
                  language: filteredLang,
                  favourites: isFavourites,
                )),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    final overlay = Overlay.of(context);
    if (overlay != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      showMenu(
          context: context,
          position: RelativeRect.fromRect(
            Rect.fromLTWH(position.dx, position.dy, 40, 40),
            Rect.fromLTWH(0, 0, screenWidth, screenHeight),
          ),
          items: <PopupMenuEntry>[
            const PopupMenuItem(
              height: 30,
              value: 'Favourites',
              child: SizedBox(
                height: 22,
                child: Row(
                  children: [
                    Text('Favourites'),
                  ],
                ),
              ),
            ),
            const PopupMenuDivider(
              height: 3,
            ),
            const PopupMenuItem(
              height: 30,
              value: 'Devotional',
              child: SizedBox(
                height: 22,
                child: Row(
                  children: [
                    Text('Devotional'),
                  ],
                ),
              ),
            ),
            const PopupMenuItem(
              height: 30,
              value: 'English',
              child: SizedBox(
                height: 22,
                child: Row(
                  children: [
                    Text('English'),
                  ],
                ),
              ),
            ),
            const PopupMenuItem(
              height: 30,
              value: 'Hindi',
              child: SizedBox(
                height: 22,
                child: Row(
                  children: [
                    Text('Hindi'),
                  ],
                ),
              ),
            ),
            const PopupMenuItem(
              height: 30,
              value: 'Tamil',
              child: SizedBox(
                height: 22,
                child: Row(
                  children: [
                    Text('Tamil'),
                  ],
                ),
              ),
            ),
          ]).then((value) {
        if (value == 'Favourites') {
          isFavourites = 'Y';
        } else {
          filteredLang = value;
        }
        _storePosition;
      });
    } else {
      print('Error: overlay is null');
    }
  }

  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(
        backgroundBlendMode: BlendMode.clear,
        color: Colors.black,
      ),
      child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextScroll(
              'Online FM Radio Player By Kumar Sundaram',
              mode: TextScrollMode.bouncing,
              velocity: Velocity(pixelsPerSecond: Offset(25, 0)),
              delayBefore: Duration(milliseconds: 500),
              pauseBetween: Duration(milliseconds: 50),
              style: TextStyle(
                backgroundColor: Colors.black,
                color: Colors.white,
              ),
              selectable: true,
            ),
          ]),
    );
  }

  // Rotated Text for Sidebar
  Widget menuText(String text, String value, {bool isSelected = false}) {
    SharedPrefsApi.getFilter().then((filter) {
      print('filter is ----> $filter --> $filteredLang --> $value');
      // isFavourites = filter == 'Favourites' ? 'Y' : filteredLang == value;
      // isSelected = isFavourites == 'Y'
      //     ? true
      //     : filter == value
      //         ? true
      //         : filteredLang == value;

      if (isFavourites == 'Y') {
        isSelected = true;
      } else if (filter == value) {
        isSelected = true;
      } else if (filteredLang == value) {
        isSelected = true;
      } else {
        isSelected = false;
      }
    });
    print('isSelected is $isSelected');
    return GestureDetector(
      onTapDown: (details) {
        SharedPrefsApi.setFilter(value);
        if (value == 'Favourites') {
          isFavourites = 'Y';
        } else {
          filteredLang = value;
        }
      },
      child: RotatedBox(
        quarterTurns: -1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
