import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/apis/shared_prefs_api.dart';
import 'package:live_radio/models/radio_station_model.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:live_radio/utils/radio_stations.dart';
import 'package:provider/provider.dart';

class RadioList extends StatefulWidget {
  final String language;
  const RadioList({super.key, required this.language});

  @override
  State<RadioList> createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {
  late RadioStation selectedStation;
  late RadioProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<RadioProvider>(context, listen: false);
    selectedStation = provider.station;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context, listen: false);
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
        if (station.language == widget.language) {
          return Container(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Colors.pink, Colors.deepPurple])
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
                // print(SharedPrefsApi.filterStations('English'));
                await RadioApi.changeStation(station);
                setState(() {
                  selectedStation = station;
                });
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
