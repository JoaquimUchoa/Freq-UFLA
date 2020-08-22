import 'package:flutter/material.dart';


class StudentHome extends StatefulWidget {
  StudentHome({Key key, this.userId, this.logoutCallback})
      : super(key: key);

  final VoidCallback logoutCallback;
  final String userId;

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("StudentHome"),
        ),
        body: Text("StudentHome")
    );
  }
}
