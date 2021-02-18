import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/views/city.dart';
import 'package:prayer_times/views/prayers.dart';
import 'package:prayer_times/views/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'models/prayers.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      theme: ThemeData(
        primaryColor: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Prayer Times'),
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
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String current = '';
  String currentHour = '';
  String city = '';

  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCity();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new Settings(
                          city: this.city,
                          connectionStatus: _connectionStatus)),
                ).then((value) => setState(() {
                      _loadCity();
                    }));
              }),
        ],
      ),
      body: _showCurrentPrayer(),
    );
  }

  //Get the current prayer
  Widget _showCurrentPrayer() {
    return Center(
        child: new GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new PrayersList(prayers: getPrayers())));
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

    int doh = int.parse(dohr.substring(0, 2));
    int ash = int.parse(asr.substring(0, 2));
    int ma = int.parse(maghrib.substring(0, 2));
    int ish = int.parse(isha.substring(0, 2));

    if (now.hour < doh) {
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

  //Get prayers from API
  Future<Prayer> getPrayers() async {
    final String url = 'https://api.pray.zone/v2/times/today.json?city=' + city;

    if (city != 'none') {
      if (_connectionStatus == 'ConnectivityResult.wifi' ||
          _connectionStatus == 'ConnectivityResult.mobile') {
        final response =
            await http.get(url, headers: {"Accept": "application/json"});

        if (response.statusCode == 200) {
          return Prayer.fromJSON(json.decode(response.body));
        } else {
          throw Exception("Can't get data ! Please retry after.");
        }
      } else {
        throw Exception("No Internet connection ! Please, check your network.");
      }
    } else {
      return null;
    }
  }

  Future<void> _loadCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      city = prefs.getString('city') ?? "none";
    });

    if (city == 'none') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new City(city: this.city, connectionStatus: _connectionStatus,)),
      );
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
}
