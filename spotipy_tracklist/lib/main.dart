import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<List<Track>> fetchPost() async {
  final response =
  await http.get('path-to-tracklist');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    List<Track> tracklist = new List<Track>();
    List<dynamic> list = json.decode(response.body);
    for(var i = 0; i < list.length; i++) {
      tracklist.add(Track.fromJson(list[i]));
    }

    return tracklist;
  } else {
    throw Exception('Failed to load post');
  }
}

class Track {
  final String name;
  final String artists;
  final String album;
  final String playedDate;
  final String externalUrl;
  final String thumbnailUrl;

  Track({this.name, this.artists, this.album, this.playedDate, this.externalUrl, this.thumbnailUrl});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      name: json['name'],
      artists: json['artists'].join(", "),
      album: json['album'],
      playedDate: json['played_date'],
      externalUrl: json['external_url'],
      thumbnailUrl: json['thumbnail'],
    );
  }
}

void main() => runApp(MyApp(track: fetchPost()));


void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class MyApp extends StatelessWidget {
  final Future<List<Track>> track;

  MyApp({Key key, this.track}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotipy Tracklist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Spotipy Tracklist'),
        ),
        body: Center(
          child: FutureBuilder<List<Track>>(
            future:track,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: new NetworkImage(snapshot.data[index].thumbnailUrl),
                            ),
                            title: Text('Artist: ${snapshot.data[index].artists}'),
                            subtitle: Text('Song: ${snapshot.data[index].name}\nAlbum: ${snapshot.data[index].album}\nPlayed at: ${snapshot.data[index].playedDate}'),
                            onTap:() {
                              launchURL(snapshot.data[index].externalUrl);
                            }
                        ),
                      );
                    }
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
