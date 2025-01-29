import 'package:flutter/material.dart';
import 'package:live_radio/apis/radio_api.dart';
import 'package:live_radio/widgets/radio_player.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget build(BuildContext context) {
    // return _buildMenu(context);
    return Container(
      decoration: const BoxDecoration(),
      //background image
      // decoration: const BoxDecoration(
      //     image: DecorationImage(
      //         image: AssetImage("assets/radiobg.jpg"), fit: BoxFit.contain)),
      child: Scaffold(
        backgroundColor: const Color(0x00E5E5E5),
        body: FutureBuilder(
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

  Widget _buildMenu(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Vertical Menu
          // Container(
          //   width: 60, // Small sidebar width
          //   color: Colors.black,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       const SizedBox(height: 50),
          //       Positioned(
          //         top: 0,
          //         left: 0,
          //         child: Image.asset("assets/radio.png", width: 50),
          //       ),
          //       const SizedBox(height: 50),
          //       menuText("Favorites", isSelected: true),
          //       const SizedBox(height: 20),
          //       menuText("Devotional"),
          //       const SizedBox(height: 20),
          //       menuText("Entertainment"),
          //       const SizedBox(height: 20),
          //       menuText("Hindi"),
          //       const SizedBox(height: 20),
          //       menuText("Tamil"),
          //       // isSelected: true), // Selected item highlighted
          //     ],
          //   ),
          // ),

          // Main Content
          Container(
            width: MediaQuery.of(context).size.width - 60,
            //background image
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/radiobg.jpg"), fit: BoxFit.fill)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: FutureBuilder(
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
          )
        ],
      ),
    );
  }

// // Rotated Text for Sidebar
//   Widget menuText(String text, {bool isSelected = false}) {
//     return RotatedBox(
//       quarterTurns: -1,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 16,
//             color: isSelected ? Colors.white : Colors.grey,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
}
