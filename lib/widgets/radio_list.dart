import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/apis/shared_prefs_api.dart';
import 'package:live_radio/models/radio_station_model.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:live_radio/utils/radio_stations.dart';
import 'package:live_radio/widgets/radio_player.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
      print(favouritesList);
      // You can also call setState here to update the UI
    });
    // You can also call setState here to update the UI
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context, listen: false);

    print(widget.language);
    print(widget.favourites);

    // if (widget.favourites == 'Y') {
    //   SharedPrefsApi.getFavourites().then((favourites) {
    //     favouritesList = favourites;
    //     print(favouritesList);
    //     // You can also call setState here to update the UI
    //   });
    // }

    RadioStations.allStations
        .sort((a, b) => a.name.compareTo(b.name)); // sort the stations by name
    return ListView.builder(
      itemCount: RadioStations.allStations.length,
      itemBuilder: (context, index) {
        final station = RadioStations.allStations[index];
        bool isSelected = station.name == provider.station.name;

        var photoURL = station.photoURL == ''
            ? Image.asset('assets/radio.png',
                width: 30, height: 30, fit: BoxFit.cover)
            : Image.asset(station.photoURL,
                width: 50, height: 50, fit: BoxFit.cover);
        if (widget.favourites == 'Y') {
          if (favouritesList.any((e) => e.toString().contains(station.name))) {
            return Slidable(
                startActionPane:
                    ActionPane(motion: const StretchMotion(), children: [
                  // Add to Station to favourites
                  CustomSlidableAction(
                    //add provision to remove from fav
                    // show a toast after completing operation
                    onPressed: (context) {
                      SharedPrefsApi.removeFavourite(station);
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
                endActionPane:
                    ActionPane(motion: const StretchMotion(), children: [
                  // Add to Station to favourites
                  CustomSlidableAction(
                    onPressed: (context) {
                      SharedPrefsApi.setFavourites(station);
                    },
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ]),
                child:
                    _buildStationList(context, isSelected, station, photoURL));
          } else {
            return const SizedBox.shrink();
          }
        } else if (station.language == widget.language) {
          // filter the stations based on the language
          return Slidable(
              startActionPane:
                  ActionPane(motion: const StretchMotion(), children: [
                // Add to Station to favourites
                CustomSlidableAction(
                  //add provision to remove from fav
                  // show a toast after completing operation
                  onPressed: (context) {
                    SharedPrefsApi.removeFavourite(station);
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
              endActionPane:
                  ActionPane(motion: const StretchMotion(), children: [
                // Add to Station to favourites
                CustomSlidableAction(
                  //add provision to remove from fav
                  // show a toast after completing operation
                  onPressed: (context) {
                    SharedPrefsApi.setFavourites(station);
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
              child: _buildStationList(context, isSelected, station, photoURL));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  // Widget _buildSlidableList(
  //     BuildContext context, isSelected, station, photoURL) {

  // }

  Widget _buildStationList(
      BuildContext context, isSelected, station, photoURL) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(colors: [Colors.pink, Colors.deepPurple])
            : null,
      ),
      child: ListTile(
        leading: photoURL,
        horizontalTitleGap: 20,
        title: Text(
          station.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
      ),
    );
  }
}
