import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'models/prayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time To Pray',
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Time To Pray'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String current = '';
  String currentHour = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: _setting),
        ],
      ),
      body: _showCurrentPrayer(),
    );
  }

  void _setting() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: ListView(children: <Widget>[
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text(
              'Paris',
              style: TextStyle(
                fontFamily: 'Candara',
                fontSize: 17,
              ),
            ),
            trailing: Icon(Icons.edit),
          )
        ]),
      );
    }));
  }

  void _prayersList() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Prayers'),
        ),
        body: Center(
          child: FutureBuilder<Prayer>(
            future: getPrayers(),
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
        ),
      );
    }));
  }

  //Get the current prayer
  Widget _showCurrentPrayer() {
    return Center(
        child: new GestureDetector(
      onTap: () {
        _prayersList(); //Show all the prayers
      },
      child: FutureBuilder<Prayer>(
        future: getPrayers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            getHour(snapshot.data.fajr, snapshot.data.dhuhr, snapshot.data.asr,
                snapshot.data.maghrib, snapshot.data.isha);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    current,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Candara',
                      fontSize: 50,
                    ),
                  ),
                  Text(
                    currentHour,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Candara',
                      fontSize: 30,
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    ));
  }

  //Check the actual time and return the current prayer
  String getHour(
      String fajr, String dohr, String asr, String maghrib, String isha) {
    DateTime now = new DateTime.now();

    int fa = int.parse(fajr.substring(0, 2));
    int doh = int.parse(dohr.substring(0, 2));
    int ash = int.parse(asr.substring(0, 2));
    int ma = int.parse(maghrib.substring(0, 2));
    int ish = int.parse(isha.substring(0, 2));

    if (now.hour >= fa && now.hour < doh) {
      this.current = 'Fajr';
      this.currentHour = fajr;
    } else if (now.hour >= doh && now.hour < ash) {
      this.current = 'Dhuhr';
      this.currentHour = dohr;
    } else if (now.hour >= ash && now.hour < ma) {
      this.current = 'Asr';
      this.currentHour = asr;
    } else if (now.hour >= ma && now.hour < ish) {
      this.current = 'Maghrib';
      this.currentHour = maghrib;
    } else if (now.hour >= ish) {
      this.current = 'Isha';
      this.currentHour = isha;
    }

    return '';
  }
}

//Get prayers from API
Future<Prayer> getPrayers() async {
  final String url = 'https://api.pray.zone/v2/times/today.json?city=blois';

  final response = await http.get(url, headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    return Prayer.fromJSON(json.decode(response.body));
  } else {
    throw Exception("Can't get data.");
  }
}
