import 'package:flutter/material.dart';

class GeneralAlertDialog extends StatelessWidget {
  GeneralAlertDialog({this.title, this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.title),
      content: Text(this.content),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed:  () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
