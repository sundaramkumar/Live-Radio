import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/apis/shared_prefs_api.dart';
import 'package:live_radio/models/radio_station_model.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:live_radio/utils/radio_stations.dart';
import 'package:live_radio/widgets/radio_player.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../pages/current_station_page.dart';
import '../utils/toast.dart';

class RadioList extends StatefulWidget {
  final String language;
  final String favourites;
  const RadioList({
    super.key,
    required this.language,
    required this.favourites,
  });

  @override
  State<RadioList> createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {
  late RadioStation selectedStation;
  late RadioProvider provider;
  late List<String> favouritesList = [];
  late List<RadioStation> stationsList = [];
  @override
  void initState() {
    super.initState();
    provider = Provider.of<RadioProvider>(context, listen: false);
    selectedStation = provider.station;
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    // favouritesList = await SharedPrefsApi.getFavourites();
    SharedPrefsApi.getFavourites().then((favourites) {
      favouritesList = favourites;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context, listen: false);

    RadioStations.allStations
        .sort((a, b) => a.name.compareTo(b.name)); // sort the stations by name
    // print(widget.favourites);
    // print('language is ${widget.language}');
    var stationsListLength = widget.favourites == 'Y'
        ? favouritesList.length
        : RadioStations.allStations
            .where((station) => station.language == widget.language)
            .length;
    stationsList = widget.favourites == 'Y'
        ? RadioStations.allStations
            .where((station) => favouritesList.contains(station.name))
            .toList()
        : RadioStations.allStations
            .where((station) => station.language == widget.language)
            .toList();

    return GridView.count(
      semanticChildCount: stationsListLength,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      padding: const EdgeInsets.only(top: 10),
      children: stationsList.map((station) {
        // final station = RadioStations.allStations[index];
        bool isSelected = station.name == provider.station.name;
        var photoURL = station.photoURL == ''
            ? Image.asset('assets/radio.png',
                width: 100, height: 100, fit: BoxFit.fill)
            : Image.asset(station.photoURL,
                width: 100, height: 100, fit: BoxFit.fill);
        if (widget.favourites == 'Y') {
          return _buildFavouriteStation(context, station, isSelected, photoURL);
        } else if (station.language == widget.language) {
          return radioStationCard(context, station, isSelected, photoURL);
        } else {
          return const SizedBox.shrink(); // or return any other widget
        }
      }).toList(),
    );
  }

  Widget _buildFavouriteStation(BuildContext context, RadioStation station,
      bool isSelected, Image photoURL) {
    // if (favouritesList.any((e) => e.toString().contains(station.name))) {
    return InkWell(
        onTap: () async {
          provider.setRadioStation(station);
          SharedPrefsApi.setStation(station);
          SharedPrefsApi.currentStation = station.name;
          // print(SharedPrefsApi.filterStations('English'));
          await RadioApi.changeStation(station);
          _onStationTapped(context, station);
          setState(() {
            selectedStation = station;
          });
        },
        child: SizedBox(
          height: 100,
          width: 100,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 0.5),
              // isSelected, set the color
              // color: isSelected ? Colors.pinkAccent : Color(0x0032324E),
              borderRadius: BorderRadius.circular(12),
              // or set the image if isSelected
              image: isSelected
                  ? const DecorationImage(
                      image: AssetImage('assets/eqbg.gif'),
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(station.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    )),
                // or show the equalizer if isSelected
                // isSelected
                //     ? _cardEqualizer()
                //     :
                const SizedBox(
                  width: 75,
                  height: 35,
                ),
                _buildStationWave()
              ],
            ),
          ),
        ));
    // } else {
    //   return const SizedBox.shrink();
    // }
  }

  Widget radioStationCard(BuildContext context, RadioStation station,
      bool isSelected, Image photoURL) {
    return InkWell(
        onTap: () async {
          provider.setRadioStation(station);
          SharedPrefsApi.setStation(station);
          SharedPrefsApi.currentStation = station.name;
          // print(SharedPrefsApi.filterStations('English'));
          await RadioApi.changeStation(station);
          _onStationTapped(context, station);
          setState(() {
            selectedStation = station;
          });
        },
        child: SizedBox(
          height: 100,
          width: 100,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 0.5),
              // isSelected, set the color
              // color: isSelected ? Colors.pinkAccent : Color(0x0032324E),
              borderRadius: BorderRadius.circular(12),
              // or set the image if isSelected
              image: isSelected
                  ? const DecorationImage(
                      image: AssetImage('assets/eqbg.gif'),
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(station.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    )),
                // or show the equalizer if isSelected
                // isSelected
                //     ? _cardEqualizer()
                //     :
                const SizedBox(
                  width: 75,
                  height: 35,
                ),
                _buildStationWave()
              ],
            ),
          ),
        ));
  }

  void _onStationTapped(BuildContext context, RadioStation station) {
    final provider = Provider.of<RadioProvider>(context, listen: false);
    provider.setRadioStation(station);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CurrentStationPage()),
    );
  }

  Widget _cardEqualizer() {
    return Image.asset('assets/equalizerwave.gif',
        width: 75, height: 35, fit: BoxFit.fill);
  }

  Image _buildStationWave() {
    List<String> waves = [
      'assets/bluewave.png',
      'assets/greenwave.png',
      'assets/purplewave.png',
      'assets/yellowwave.png',
      'assets/redwave.png'
    ];
    waves.shuffle();

    return Image.asset(waves[0], width: 94, height: 23, fit: BoxFit.fill);
  }

  Widget _buildLanguageStation(BuildContext context, RadioStation station,
      bool isSelected, Image photoURL) {
    return Slidable(
      startActionPane: ActionPane(motion: const StretchMotion(), children: [
        CustomSlidableAction(
          onPressed: (context) {
            setState(() {
              SharedPrefsApi.removeFavourite(station);
              favouritesList
                  .removeWhere((e) => e.toString().contains(station.name));
            });
            showToast('Removed from Favourites');
          },
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          child: Image.asset('assets/removefavorite.png',
              width: 30, height: 30, fit: BoxFit.cover),
        )
      ]),
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        CustomSlidableAction(
          onPressed: (context) {
            setState(() {
              SharedPrefsApi.setFavourites(station);
              favouritesList.add(station.name);
            });
            showToast('Added to Favourites');
          },
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          child: Image.asset('assets/addfavorite.png',
              width: 30, height: 30, fit: BoxFit.cover),
        )
      ]),
      child: radioStationCard(context, station, isSelected, photoURL),
    );
  }
}
