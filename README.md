# Live Radio

This Flutter app plays live radio stations available online. It's a simple to use app with a list of popular radio stations. You can click on the radio station to play it. The app also supports playing the radio station in the background. The app is written in Dart and uses the Flutter framework. You can add your own online radios available.
The app is available in both Android and iOS platforms.

## Screenshots

Here are some screenshots of the Live Radio app:

### Home Screen

<img src="screenshots/home_screen.jpg" width="150" height=300>

### Radio Station List

<img src="screenshots/radio_station_list.jpg" width="150" height=300>

### Radio Station List Filter

<img src="screenshots/radio_station_list_filter.jpg" width="150" height=300>

### Radio Station List Favourite

<img src="screenshots/radio_station_list_favourites.jpg" width="150" height=300>

### Player Screen

<img src="screenshots/player_screen.jpg" width="150" height=300>

# Download the APK

Download the APK if you want to test, explore the app

- [Download APK](release/app-release.apk)
- [SHA1 Hash] 27f824082cd655afd4da68a8f67ba4517b163678

## Getting Started

Follow these steps to build and run the Live Radio app on your local machine:

### Prerequisites

1. **Flutter SDK**: Ensure you have Flutter installed. You can download it from the [official Flutter website](https://flutter.dev/docs/get-started/install).
2. **Dart SDK**: Dart is included with Flutter, so no separate installation is needed.
3. **Android Studio**: For Android development, install [Android Studio](https://developer.android.com/studio).
4. **Xcode**: For iOS development, install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store.
5. **VS Code**: (Optional) Install [Visual Studio Code](https://code.visualstudio.com/) for a lightweight code editor.

### Installation

1. **Clone the repository**:

   ```sh
   git clone https://github.com/sundaramkumar/Live-Radio.git
   cd live_radio
   ```

2. **Install dependencies**:
   ```sh
   flutter pub get
   ```

### Running the App

#### On Android

1. **Start an Android emulator** or connect an Android device.
2. **Run the app**:
   ```sh
   flutter run
   ```

#### On iOS

1. **Open the iOS project in Xcode**:
   ```sh
   open ios/Runner.xcworkspace
   ```
2. **Select a simulator** or connect an iOS device.
3. **Run the app**:
   - In Xcode, click the play button or run:
   ```sh
   flutter run
   ```

### Building for Production

#### Android

1. **Build the APK**:

   ```sh
   flutter build apk --release
   ```

2. The APK will be located in `build/app/outputs/flutter-apk/app-release.apk`.

#### iOS

1. **Build the iOS app**:

   ```sh
   flutter build ios --release
   ```

2. The build will be located in `build/ios/iphoneos/`.

### Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Android Studio Documentation](https://developer.android.com/studio/intro)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)

## TODO

- fetch artwork from player api
- better ui
- border radius for radio station image
- find a station is offline - implemented the method, but shows always once a state is changed
