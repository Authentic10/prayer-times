import 'package:flutter/material.dart';
import 'city.dart';

class Settings extends StatelessWidget {
  final String city;
  final String connectionStatus;

  Settings({Key key, @required this.city, @required this.connectionStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('Settings'),
        ),
        body: _setting(context, this.city));
  }

  Widget _setting(BuildContext context, String c) {
    String city = '';
    
    if(c != 'none'){
      city = c;
    }
    
    return ListView(children: <Widget>[
      ListTile(
        leading: Icon(Icons.location_city),
        title: Text(
          city,
          style: TextStyle(
            fontFamily: 'Candara',
            fontSize: 17,
          ),
        ),
        trailing: Icon(Icons.edit),
        onTap: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new City(city: this.city, connectionStatus: this.connectionStatus)));
          city = "$result".toString();
          if (city != this.city) Navigator.pop(context);
        },
      )
    ]);
  }
}
