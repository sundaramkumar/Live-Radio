import 'package:live_radio/models/radio_station_model.dart';
import 'package:http/http.dart' as http;

class RadioStations {
  static List<RadioStation> allStations = [
    RadioStation(
      name: 'Big FM',
      language: 'Tamil',
      streamURL: 'https://www.liveradio.es/http://tamil.crabdance.com:8002/4',
      photoURL: 'assets/big-fm-chennai-online.jpg',
    ),
    RadioStation(
      name: 'SPB Hits',
      language: 'Tamil',
      streamURL: 'https://stream.zeno.fm/9adkzdcqi4jvv',
      photoURL: 'assets/spbhits.png',
    ),
    RadioStation(
      name: 'Sooriyan FM',
      language: 'Tamil',
      streamURL: 'https://radio.lotustechnologieslk.net:8006/;stream.mp3',
      photoURL: 'assets/sooryanfm.jpg',
    ),
    RadioStation(
      name: 'SLBC Tamil National Service',
      language: 'Tamil',
      streamURL: 'https://www.liveradio.es/http://220.247.227.6:8000/Tnsstream',
      photoURL: 'assets/slbctamil.jpg',
    ),
    RadioStation(
      name: 'Raaga FM',
      language: 'Tamil',
      streamURL: 'https://listen.openstream.co/7044/audio',
      photoURL: 'assets/raagafm.jpg',
    ),
    RadioStation(
      name: 'Radio Beat Retro',
      language: 'Tamil',
      streamURL: 'https://www.liveradio.es/http://5.63.151.52:7142/stream',
      photoURL: 'assets/radiobeatretro.jpg',
    ),
    RadioStation(
      name: 'Tamil Retro FM',
      language: 'Tamil',
      streamURL: 'https://spserver.sscast2u.in/retrofmtamil/stream',
      photoURL: 'assets/tamilretrofm.jpg',
    ),
    RadioStation(
      name: 'Radio Madurai',
      language: 'Tamil',
      streamURL: 'https://stream.zeno.fm/1ycmepnthkhvv',
      photoURL: 'assets/radiomadurai.jpg',
    ),
    RadioStation(
      name: 'Kodai Ragam',
      language: 'Tamil',
      streamURL: 'https://sp.radiotamilonline.com/8006/stream',
      photoURL: 'assets/kodairagam.jpg',
    ),
    RadioStation(
      name: 'Harris Jayaraj FM',
      language: 'Tamil',
      streamURL:
          'https://stream-155.zeno.fm/ob6tjg8gulptv?zt=eyJhbGciOiJIUzI1NiJ9.eyJzdHJlYW0iOiJvYjZ0amc4Z3VscHR2IiwiaG9zdCI6InN0cmVhbS0xNTUuemVuby5mbSIsInJ0dGwiOjUsImp0aSI6IjNjWmFwcGNoUW1XeEd1UWhRVU9pcXciLCJpYXQiOjE3MzQ0NDA0NjEsImV4cCI6MTczNDQ0MDUyMX0.gH7jQ3_E5eXN9AEf5R-OMjGOCQ-cNyoeTuIGHiskS7c',
      photoURL: 'assets/harris.png',
    ),
    RadioStation(
      name: 'A.R.Rahman Hits HD',
      language: 'Tamil',
      streamURL: 'https://ec5.yesstreaming.net:2320/stream',
      photoURL: 'assets/arrfm.jpg',
    ),
    RadioStation(
      name: 'FM Rainbow - Chennai',
      language: 'Tamil',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio022/chunklist.m3u8',
      photoURL: 'assets/fmrainbowchennai.jpg',
    ),
    RadioStation(
      name: 'AIR Tirunelveli FM',
      language: 'Tamil',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio062/chunklist.m3u8',
      photoURL: 'assets/aircoimbatore.jpg',
    ),
    RadioStation(
      name: 'AIR Kodai FM',
      language: 'Tamil',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio051/chunklist.m3u8',
      photoURL: 'assets/kodaifm.jpg',
    ),
    RadioStation(
      name: 'Radio Gilli',
      language: 'Tamil',
      streamURL: 'https://stream3.rcast.net/66462.mp3',
      photoURL: 'assets/radiogilli.jpg',
    ),
    RadioStation(
      name: 'Hello FM',
      language: 'Tamil',
      streamURL: 'https://strw3.openstream.co/606',
      photoURL: 'assets/hellofm.jpg',
    ),
    RadioStation(
      name: 'Bollywood Classic Songs 1',
      language: 'Hindi',
      streamURL:
          'http://node-12.zeno.fm/60ef4p33vxquv?rj-ttl=5&rj-tok=AAABc-OCFngAs_AvDsY_StEpMg',
      photoURL: 'assets/bollywood.jpg',
    ),
    RadioStation(
      name: 'Bollywood Classic Songs 2',
      language: 'Hindi',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio088/playlist.m3u8',
      photoURL: 'assets/bollywood.jpg',
    ),
    RadioStation(
      name: 'Lanka Sri FM',
      language: 'Tamil',
      streamURL: 'https://www.liveradio.es/5984.cloudrad.io:8032/;stream.mp3',
      photoURL: 'assets/lankasri.jpg',
    ),
    RadioStation(
      name: 'Vivasaayi FM',
      language: 'Tamil',
      streamURL: 'https://stream.zeno.fm/5mm4974xk2zuv',
      photoURL: 'assets/Vivasaayi.jpg',
    ),
    RadioStation(
      name: 'BBC Radio 4',
      language: 'English',
      streamURL:
          'https://a.files.bbci.co.uk/ms6/live/3441A116-B12E-4D2F-ACA8-C1984642FA4B/audio/simulcast/dash/nonuk/pc_hd_abr_v2/aks/bbc_radio_fourfm.mpd',
      photoURL: 'assets/bb4.png',
    ),
    RadioStation(
      name: 'Radio Mirchi Tamil',
      language: 'Tamil',
      streamURL: 'https://www.liveradio.es/http://tamil.crabdance.com:8002/1',
      photoURL: 'assets/radiomirchi.jpg',
    ),
    RadioStation(
      name: 'Vadivelu Comedy Radio',
      language: 'Tamil',
      streamURL:
          'https://stream-155.zeno.fm/02n962ezyp8uv?zt=eyJhbGciOiJIUzI1NiJ9.eyJzdHJlYW0iOiIwMm45NjJlenlwOHV2IiwiaG9zdCI6InN0cmVhbS0xNTUuemVuby5mbSIsInJ0dGwiOjUsImp0aSI6IkhmcHotNm5zVGQ2MGFHVE1JUmVIWUEiLCJpYXQiOjE3MzUxOTk5NDUsImV4cCI6MTczNTIwMDAwNX0.ojRFrX4AD4JbKiDcCWHNd_jDNDnkWcmR0xM2d917d_o',
      photoURL: 'assets/vadivelucomedy.jpg',
    ),
    RadioStation(
      name: 'Tamil sun FM Radio',
      language: 'Tamil',
      streamURL: 'https://usa2.fastcast4u.com/proxy/tamilsun?mp=/;',
      photoURL: 'assets/tamilsunfm.jpg',
    ),
    RadioStation(
      name: 'Radio City Chennai',
      language: 'Tamil',
      streamURL: 'https://www.liveradio.es/http://tamil.crabdance.com:8002/5',
      photoURL: 'assets/radiocitychennai.jpg',
    ),
    RadioStation(
      name: 'ILayaraja Radio online',
      language: 'Tamil',
      streamURL: 'https://server.geetradio.com:8100/radio.mp3',
      photoURL: 'assets/ilayaraja.jpg',
    ),
    RadioStation(
      name: 'Vividh Bharati Chennai',
      language: 'Tamil',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio024/chunklist.m3u8',
      photoURL: 'assets/VividhBharatiChennai.jpg',
    ),
    RadioStation(
      name: 'Tamil Kuyil',
      language: 'Tamil',
      streamURL: 'http://live.tamilkuyilradio.com:8095/;',
      photoURL: 'assets/tamilkuyil.png',
    ),
    RadioStation(
      name: 'Tamil Maalai',
      language: 'Tamil',
      streamURL: 'http://www.s1.cmesolution.my:8808/;',
      photoURL: 'assets/tamilmaalai.jpg',
    ),
    RadioStation(
      name: 'FM Gold',
      language: 'Tamil',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio021/chunklist.m3u8',
      photoURL: 'assets/fmgold.jpg',
    ),
    RadioStation(
      name: 'AIR Tamil',
      language: 'Tamil',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio025/chunklist.m3u8',
      photoURL: 'assets/aircoimbatore.jpg',
    ),
    RadioStation(
      name: 'AIR Coimbatore',
      language: 'Tamil',
      streamURL:
          'https://air.pc.cdn.bitgravity.com/air/live/pbaudio016/playlist.m3u8',
      photoURL: 'assets/aircoimbatore.jpg',
    ),
    RadioStation(
      name: 'Mohan Hits Radio',
      language: 'Tamil',
      streamURL:
          'https://stream-158.zeno.fm/wkqvzsg1238uv?zt=eyJhbGciOiJIUzI1NiJ9.eyJzdHJlYW0iOiJ3a3F2enNnMTIzOHV2IiwiaG9zdCI6InN0cmVhbS0xNTguemVuby5mbSIsInJ0dGwiOjUsImp0aSI6ImY2M1Uta1Y5U2UtTE9sVGlHVExpZXciLCJpYXQiOjE3MzUzMTE3NTksImV4cCI6MTczNTMxMTgxOX0.9qVCM-8HvNlFr5yKnvvbvCJGRlAy2A_19_A31y0vESE',
      photoURL: 'assets/mohan.jpg',
    ),
    RadioStation(
      name: 'Vijay Radio Online',
      language: 'Tamil',
      streamURL:
          'https://stream-153.zeno.fm/3w6g61p7pa0uv?zt=eyJhbGciOiJIUzI1NiJ9.eyJzdHJlYW0iOiIzdzZnNjFwN3BhMHV2IiwiaG9zdCI6InN0cmVhbS0xNTMuemVuby5mbSIsInJ0dGwiOjUsImp0aSI6IjZFVG1nU3pZUjJPTktMeUs3TDg3NWciLCJpYXQiOjE3MzUzMTE4ODcsImV4cCI6MTczNTMxMTk0N30.xUNP4orOlX-V2nx6vDE0u4Q_CQkUe_jQ_ffmEun7U_A',
      photoURL: 'assets/vijayradio.jpg',
    ),
    RadioStation(
      name: 'GV Prakash Online',
      language: 'Tamil',
      streamURL:
          'https://stream-174.zeno.fm/d5skwct7hqzuv?zt=eyJhbGciOiJIUzI1NiJ9.eyJzdHJlYW0iOiJkNXNrd2N0N2hxenV2IiwiaG9zdCI6InN0cmVhbS0xNzQuemVuby5mbSIsInJ0dGwiOjUsImp0aSI6InNvd3RMd0dnU3NpVzZFS1JhNjZUOVEiLCJpYXQiOjE3MzUzMTE5NjMsImV4cCI6MTczNTMxMjAyM30.2Sb0jW_NQ9mjvm4jOj_iif__ZtisA5F4xu_dRyK3WaQ',
      photoURL: 'assets/gvprakash.jpg',
    ),
    RadioStation(
      name: 'IBC Tamil',
      language: 'Tamil',
      streamURL:
          'https://stream-174.zeno.fm/d5skwct7hqzuv?zt=eyJhbGciOiJIUzI1NiJ9.eyJzdHJlYW0iOiJkNXNrd2N0N2hxenV2IiwiaG9zdCI6InN0cmVhbS0xNzQuemVuby5mbSIsInJ0dGwiOjUsImp0aSI6InNvd3RMd0dnU3NpVzZFS1JhNjZUOVEiLCJpYXQiOjE3MzUzMTE5NjMsImV4cCI6MTczNTMxMjAyM30.2Sb0jW_NQ9mjvm4jOj_iif__ZtisA5F4xu_dRyK3WaQ',
      photoURL: 'assets/ibctamil.jpg',
    ),
    RadioStation(
      name: 'Bombay Beats Radio',
      language: 'Hindi',
      streamURL: 'https://strmreg.1.fm/bombaybeats_mobile_mp3',
      photoURL: 'assets/bombaybeats.jpg',
    ),
    RadioStation(
      name: 'Lata Mangeshkar Radio',
      language: 'Hindi',
      streamURL: 'https://stream.zeno.fm/87xam8pf7tzuv',
      photoURL: 'assets/latamangeshkarradio.jpg',
    ),
    RadioStation(
      name: 'Shreya Ghosal Bollywood Radio',
      language: 'Hindi',
      streamURL:
          'https://drive.uber.radio/uber/bollywoodshreyaghosal/icecast.audio',
      photoURL: 'assets/shreyaghosal.jpg',
    ),
    RadioStation(
      name: 'Bolly Hits radio net Radio',
      language: 'Hindi',
      streamURL: 'https://a4.siar.us/listen/bollyhitsradionet/stream',
      photoURL: 'assets/bollyhitsradionet.jpg',
    ),
    RadioStation(
      name: 'Dheen Osai Radio',
      language: 'Devotional',
      streamURL: 'https://stream.zenolive.com/1q8nqmk8fwzuv.aac',
      photoURL: 'assets/dheen-osai-radio.jpg',
    ),
    RadioStation(
      name: 'Vaariyar Radio',
      language: 'Devotional',
      streamURL: 'https://stream.zenolive.com/su1uch6mb2zuv.aac',
      photoURL: 'assets/vaariyaar-radio.jpg',
    ),
    RadioStation(
      name: 'Nagore EM Hanifa Radio',
      language: 'Devotional',
      streamURL: 'https://stream.zenolive.com/y8sz1kfdy4zuv.aac',
      photoURL: 'assets/nagore-em-hanifa-radio.jpg',
    ),
    RadioStation(
      name: 'Thuthi FM',
      language: 'Devotional',
      streamURL: 'https://streams.radio.co/s790fe269d/listen',
      photoURL: 'assets/thuthifm.jpg',
    ),
    RadioStation(
      name: 'Arulvakku (christian) FM',
      language: 'Devotional',
      streamURL: 'https://stream.arulvakku.com/radio/8000/radio.mp3',
      photoURL: 'assets/arulvakku-fm.jpg',
    ),
    RadioStation(
      name: 'Sivan Koil Bakthi FM',
      language: 'Devotional',
      streamURL: 'https://stream.zeno.fm/hm9s230a4qzuv',
      photoURL: 'assets/sivan_kovil_bakthi_fm.jpg',
    ),
    RadioStation(
      name: 'Om Radio',
      language: 'Devotional',
      streamURL:
          'https://playerservices.streamtheworld.com/api/livestream-redirect/OMRADIO_S01AAC_SC',
      photoURL: 'assets/om-radio.jpg',
    ),
    RadioStation(
      name: 'Bakthi FM',
      language: 'Devotional',
      streamURL: 'https://www.liveradio.es/http://listen.shoutcast.com/bakthi',
      photoURL: 'assets/bakthi-fm.jpg',
    ),
    RadioStation(
      name: 'NDTV',
      language: 'English',
      streamURL:
          'https://ndtv24x7elemarchana.akamaized.net/hls/live/2003678/ndtv24x7/ndtv24x7master.m3u8',
      photoURL: 'assets/bakthi-fm.jpg',
    ),
    RadioStation(
      name: 'CNN',
      language: 'English',
      streamURL: 'https://tunein.cdnstream1.com/3519_96.aac',
      photoURL: 'assets/cnn.png',
    ),
    RadioStation(
      name: 'AIR 1 Radio',
      language: 'English',
      streamURL: 'https://maestro.emfcdn.com/stream_for/air1/tunein/aac',
      photoURL: 'assets/air1.png',
    ),
    RadioStation(
      name: 'Vijaya FM',
      language: 'Tamil',
      streamURL: 'https://vijayfm-prabak78.radioca.st/stream',
      photoURL: 'assets/vijayafm.png',
    ),
  ];
}

Future<bool> isStationOffline(String streamUrl) async {
  try {
    final response = await http.get(Uri.parse(streamUrl));
    if (response.statusCode == 200) {
      return false; // Station is online
    } else {
      return true; // Station is offline
    }
  } catch (e) {
    return true; // Station is offline
  }
}
