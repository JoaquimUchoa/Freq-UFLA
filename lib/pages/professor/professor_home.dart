import 'package:flutter/material.dart';


class ProfessorHome extends StatefulWidget {
  ProfessorHome({Key key, this.userId, this.logoutCallback})
      : super(key: key);

  final VoidCallback logoutCallback;
  final String userId;

  @override
  _ProfessorHomeState createState() => _ProfessorHomeState();
}

class _ProfessorHomeState extends State<ProfessorHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ProfessorHome"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: widget.logoutCallback,
            ),
          ],
        ),
        body: Text("ProfessorHome")
    );
  }
}
