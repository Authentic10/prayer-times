import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import '../models/prayers.dart';

class PrayersList extends StatelessWidget {


  final Future<Prayer> prayers;

  PrayersList({Key key, @required this.prayers }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('Prayers'),
        ),
        body: _prayersList());
  }

  Widget _prayersList() {

    return Center(
        child: FutureBuilder<Prayer>(
          future: prayers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Fajr",
                      style: TextStyle(
                        fontFamily: 'Candara',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text(snapshot.data.fajr),
                    trailing: Icon(Icons.alarm),
                  ),
                  ListTile(
                    title: Text(
                      "Dhuhr",
                      style: TextStyle(
                        fontFamily: 'Candara',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text(snapshot.data.dhuhr),
                    trailing: Icon(Icons.alarm),
                  ),
                  ListTile(
                    title: Text(
                      "Asr",
                      style: TextStyle(
                        fontFamily: 'Candara',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text(snapshot.data.asr),
                    trailing: Icon(Icons.alarm),
                  ),
                  ListTile(
                    title: Text(
                      "Maghrib",
                      style: TextStyle(
                        fontFamily: 'Candara',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text(snapshot.data.maghrib),
                    trailing: Icon(Icons.alarm),
                  ),
                  ListTile(
                    title: Text(
                      "Isha",
                      style: TextStyle(
                        fontFamily: 'Candara',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text(snapshot.data.isha),
                    trailing: Icon(Icons.alarm),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      );
  }

}
