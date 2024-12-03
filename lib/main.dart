import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  String? currentTrackUrl;
  String? currentTrackTitle;

  @override
  void initState() {
    super.initState();
    fetchMusicData();
  }

  Future<void> fetchMusicData() async {
    setState(() {
      isLoading = true;
    });

    // API URL (Free Music Archive Example)
    var url = Uri.parse('https://api.freemusicarchive.org/api/track/0/1/20'); // Example endpoint
    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        isLoading = false;
        currentTrackUrl = data['data'][0]['track_file'];
        currentTrackTitle = data['data'][0]['track_title'];
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Failed to load music data.");
    }
  }

  void playMusic() async {
    if (currentTrackUrl != null) {
      try {
        await _audioPlayer.setUrl(currentTrackUrl!);
        _audioPlayer.play();
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error playing music: $e");
      }
    }
  }

  void pauseMusic() {
    _audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void stopMusic() {
    _audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                currentTrackTitle != null
                    ? Text(
                        currentTrackTitle!,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : Container(),
                SizedBox(height: 20),
                isPlaying
                    ? IconButton(
                        icon: Icon(Icons.pause, size: 40),
                        onPressed: pauseMusic,
                      )
                    : IconButton(
                        icon: Icon(Icons.play_arrow, size: 40),
                        onPressed: playMusic,
                      ),
                IconButton(
                  icon: Icon(Icons.stop, size: 40),
                  onPressed: stopMusic,
                ),
              ],
            ),
    );
  }
}
