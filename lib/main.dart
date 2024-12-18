import 'package:flutter/material.dart';
import 'package:live_radio/apis/shared_prefs_api.dart';
import 'package:live_radio/models/radio_station_model.dart';
import 'package:live_radio/pages/home_page.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final radioStation = await SharedPrefsApi.getInitialRadioStation();
  runApp(LiveRadio(
    initialStation: radioStation,
  ));
}

class LiveRadio extends StatelessWidget {
  final RadioStation initialStation;
  const LiveRadio({required this.initialStation, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: ((context) => RadioProvider(initialStation))),
      ],
      child: MaterialApp(
        title: 'Live Radio',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
      ),
    );
  }
}
