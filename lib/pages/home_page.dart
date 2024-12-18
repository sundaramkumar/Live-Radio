import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/widgets/gradient_bg.dart';
import 'package:live_radio/widgets/radio_player.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: FutureBuilder(
            future: RadioApi.initPlayer(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white,
                  ),
                );
              }
              return const RadioPlayer();
            }),
      ),
    );
  }
}
