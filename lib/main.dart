import 'package:flutter/material.dart';
import 'package:freq_ufla/pages/professor/professor_disciplina.dart';
import 'package:freq_ufla/services/authentication.dart';
import 'package:freq_ufla/pages/root.dart';
//import 'package:freq_ufla/pages/professor/professor_disciplina.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter login demo',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()),
        routes: <String, WidgetBuilder>{
          '/professor/disciplina': (BuildContext context) =>
              ProfessorDisciplina(),
        });
  }
}
