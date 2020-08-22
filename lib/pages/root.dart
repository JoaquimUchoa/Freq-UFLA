import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freq_ufla/services/authentication.dart';
import 'package:freq_ufla/pages/login/login.dart';
import 'package:freq_ufla/pages/student/student_home.dart';
import 'package:freq_ufla/pages/professor/professor_home.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  String _userId = "";
  String _registrationNumber = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
    _setStudentRegistrationNumber();
  }

  void _setStudentRegistrationNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _registrationNumber = prefs.getString('registrationNumber') ?? '';
    });
  }

  void loginCallback(bool isProfessorLogin) {
    if (isProfessorLogin) {
      widget.auth.getCurrentUser().then((user) {
        setState(() {
          _userId = user.uid.toString();
        });
      });
    }
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
      _registrationNumber = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new Login(
          auth: widget.auth,
          loginCallback: loginCallback(true),
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new StudentHome(
            userId: _userId,
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}