import 'package:flutter/material.dart';


class StudentHome extends StatefulWidget {
  StudentHome({Key key, this.registrationNumber, this.logoutCallback})
      : super(key: key);

  final VoidCallback logoutCallback;
  final String registrationNumber;

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("StudentHome"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: widget.logoutCallback,
            ),
          ],
        ),
        body: Text("StudentHome")
    );
  }
}
