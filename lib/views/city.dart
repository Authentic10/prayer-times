import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class City extends StatelessWidget {
  final myController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final String city;

  City({Key key, @required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('City'),
        ),
        body: _changeCity(context, city));
  }

  Widget _changeCity(BuildContext context, String city) {
    myController.text = city;

    return new Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter a city',
            ),
            style: TextStyle(height: 2.0),
            maxLines: 1,
            textAlign: TextAlign.center,
            autofocus: true,
            cursorColor: Colors.red,
            controller: myController,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _checkCity(context, myController.text);
                    }
                  },
                  child: Text('Submit'),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)))),
        ],
      ),
    );
  }

  void _checkCity(BuildContext context, String c) async {
 
    final String url = 'https://api.pray.zone/v2/times/today.json?city=' + c;

    final response =
        await http.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      showToast("City changed !", context, gravity: Toast.BOTTOM);
      Navigator.pop(context, c);
    } else {
      showToast("City not found, sorry !", context, gravity: Toast.BOTTOM);
    }
  }

  void showToast(String msg, BuildContext context,
      {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
