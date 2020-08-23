import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  Button(
      {this.text,
      this.textColor = Colors.white,
      this.color = Colors.blue,
      this.callbackFunc});

  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback callbackFunc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: color,
        child: Text(text, style: TextStyle(fontSize: 20.0, color: textColor)),
        onPressed: () {
          callbackFunc();
        },
      ),
    );
  }
}
