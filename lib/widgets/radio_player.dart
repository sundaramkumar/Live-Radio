import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
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
import '../providers/volume.provider.dart';
import '../utils/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../pages/current_station_page.dart';

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
  String filterName = '';

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
    final provider = Provider.of<RadioProvider>(context, listen: false);
    filteredLang = provider.station.language;
    isFavourites = 'N';
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
            height: MediaQuery.of(context).size.height,
            child: Column(
              // left side menu bar
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLeftMenu(),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 60,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/framebg.png"),
                    fit: BoxFit.fitWidth)),
            child: Padding(
              padding: const EdgeInsets.only(top: 20, right: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(isFavourites == 'Y' ? 'Favourites' : filteredLang,
                      style: GoogleFonts.aclonica(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  TextScroll('Now playing: ${selectedStation.name}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      )),
                  Expanded(
                      child: RadioList(
                    language: filteredLang,
                    favourites: isFavourites,
                  )),
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
  }

  Widget _buildLeftMenu() {
    return Column(children: [
      const SizedBox(height: 100),
      menuText("Favourites", "Favourites"),
      const SizedBox(height: 20),
      menuText("Devotional", "Devotional"),
      const SizedBox(height: 20),
      menuText("English", "English"),
      const SizedBox(height: 20),
      menuText("Hindi", "Hindi"),
      const SizedBox(height: 20),
      menuText("Tamil", "Tamil"),
      const SizedBox(height: 20),
      _buildOnlineOfflineIcon(),
      const SizedBox(height: 80),
      rotatedText("Live Radio"),
      const SizedBox(height: 25),
      rotatedLogo(),
    ]);
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
        showToast('${station.name} seems offline');
      });
    } else {
      setState(() {
        // Handle the station being online
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
      color: isMuted ? Colors.red : Colors.white,
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
            color: connectivityResult == ConnectivityResult.none
                ? Colors.red
                : Colors.cyanAccent,
            fit: BoxFit.cover),
        Text(
          connectivityResult == ConnectivityResult.none ? 'Offline' : 'Online',
          style: TextStyle(
              fontSize: 7,
              color: connectivityResult == ConnectivityResult.none
                  ? Colors.red
                  : Colors.cyanAccent),
        )
      ],
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

  // Rotated Text for Sidebar
  Widget menuText(String text, String value, {bool isSelected = false}) {
    // when the "Favourites" menu is selected, set isSelected to true only for the "Favourites" menu,
    // and false for the other menus.
    bool isFavouritesSelected = isFavourites == 'Y';

    if (isFavouritesSelected) {
      isSelected = value == 'Favourites';
    } else {
      isSelected = value == filteredLang;
    }

    SharedPrefsApi.getFilter().then((filter) {
      isSelected =
          isFavouritesSelected ? value == 'Favourites' : value == filteredLang;
    });
    return GestureDetector(
      onTapDown: (details) {
        filterName = value;
        SharedPrefsApi.setFilter(value);
        setState(() {
          if (value == 'Favourites') {
            isFavourites = 'Y';
          } else {
            filteredLang = value;
            // isFavourites = 'N';
          }
        });
      },
      child: RotatedBox(
        quarterTurns: -1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Rotated Text for Sidebar
  Widget rotatedText(String text) {
    return RotatedBox(
      quarterTurns: -1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(text,
            style: GoogleFonts.aclonica(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  Widget rotatedLogo() {
    return RotatedBox(
      quarterTurns: -1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Image.asset('assets/radio.png', width: 40),
      ),
    );
  }
}
