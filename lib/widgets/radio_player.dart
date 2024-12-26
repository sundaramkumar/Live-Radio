import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/providers/radio_provider.dart';
import 'package:live_radio/widgets/radio_list.dart';
import 'package:provider/provider.dart';

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

  bool listEnabled = false;
  bool isPlaying = true;
  List metadata = [];
  String artists = '';

  String _filteredLang = "Tamil";
  String get filteredLang => _filteredLang;
  set filteredLang(String value) {
    setState(() {
      _filteredLang = value;
    });
  }

  // var stationName = '';
  @override
  void initState() {
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    // var stationName = '';
    final provider = Provider.of<RadioProvider>(context, listen: true);
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
            child: SlideTransition(
          position: radioOffset,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 200,
                  width: 300,
                  color: Colors.transparent,
                  child: Consumer<RadioProvider>(
                      builder: ((context, value, child) {
                    artists = '';
                    var photoURL = value.station.photoURL == ''
                        ? Image.asset('assets/radio.png',
                            width: 30, height: 30, fit: BoxFit.cover)
                        : Image.asset(value.station.photoURL,
                            width: 50, height: 50, fit: BoxFit.contain);
                    // stationName = value.station.name; // RadioProvider.getRadioStation(value.station);
                    return photoURL;
                  }))),
              Text(
                provider.station.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // show artists info
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Text(artists),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                  icon: Icon(Icons.list),
                ),
                GestureDetector(
                  onTap: () => {
                    showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            _tapPosition! &
                                const Size(
                                    40, 40), // smaller rect, the touch area
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
                      // filterStationsByLanguage(value);
                      // if (value == 'Tamil') {
                      //   filterStationsByLanguage(value);
                      //   print(value);
                      // } else if (value == 'Hindi') {
                      //   print(value);
                      // } else if (value == 'English') {
                      //   print(value);
                      // }
                    })
                  },
                  onTapDown: _storePosition,
                  child: const Icon(
                    Icons.filter_alt,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    artists = '';
                    isPlaying ? RadioApi.player.stop() : RadioApi.player.play();
                  },
                  color: Colors.white,
                  iconSize: 20,
                  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {},
                  color: Colors.white,
                  iconSize: 20,
                  icon: Icon(Icons.volume_up),
                )
              ]),
            ],
          ),
        )),
        SlideTransition(
          position: radioListOffset,
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                  40,
                ))),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Radio List',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  indent: 30,
                  endIndent: 30,
                ),
                Expanded(
                    child: RadioList(
                  language: filteredLang,
                )) //
              ],
            ),
          ),
        )
      ],
    );
  }
}
