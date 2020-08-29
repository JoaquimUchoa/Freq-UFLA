import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _currentPeriod = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });

    _setStudentRegistrationNumber();
    _setConfigurations();
  }

  void _setStudentRegistrationNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _registrationNumber = prefs.getString('registrationNumber') ?? '';
    });
  }

  void _setConfigurations() async {
    Firestore.instance
        .collection('configuracoes')
        .document('periodo_atual')
        .snapshots()
        .listen((document) async {
      _currentPeriod = document.data["valor"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentPeriod', _currentPeriod);
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user.uid.toString();
        } else {
          _setStudentRegistrationNumber();
        }

        authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      widget.auth.signOut();
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
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_currentPeriod != '') {
          if (_userId.length > 0 && _userId != null) {
            return new ProfessorHome(
                userId: _userId,
                logoutCallback: logoutCallback,
                currentPeriod: _currentPeriod);
          } else if (_registrationNumber != '') {
            return StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('alunos')
                    .document(_registrationNumber)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> classes = new Map<String, dynamic>();

                    if (snapshot.data.exists) {
                      classes.addAll(snapshot.data['turmas'][_currentPeriod]);
                    }

                    return new StudentHome(
                        registrationNumber: _registrationNumber,
                        currentPeriod: _currentPeriod,
                        logoutCallback: logoutCallback,
                        classes: classes);
                  }
                  return buildWaitingScreen();
                });
          }
        }
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
