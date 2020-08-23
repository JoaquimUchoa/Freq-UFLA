import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfessorDisciplina extends StatefulWidget {
  @override
  _ProfessorDisciplinaState createState() => _ProfessorDisciplinaState();
}

class _ProfessorDisciplinaState extends State<ProfessorDisciplina> {
  var _disciplina;
  String _disciplinaName;

  void _setDisciplina(String disc) {
    setState(() {
      _disciplina = Firestore.instance
          .collection('periodos')
          .document('2020-1')
          .collection('disciplinas')
          .document(disc)
          .collection('turmas')
          .document('10A')
          .collection('aulas')
          .snapshots();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final List disc = ModalRoute.of(context).settings.arguments;
    _setDisciplina(disc[0]);
    _disciplinaName = disc[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_disciplinaName),
        ),
        body: StreamBuilder(
            stream: _disciplina,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> disciplina) {
              if (disciplina.hasError) {
                return Center(child: Text('Error: ${disciplina.error}'));
              }

              if (disciplina.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (disciplina.data.documents.length == 0) {
                return Center(child: Text('Nenhuma aula cadastrada.'));
              }

              return ListView.builder(
                  itemCount: disciplina.data.documents.length,
                  itemBuilder: (BuildContext context, int i) {
                    //print(disciplina.data.documents[i].data);
                    return ListTile(
                        title: Text(
                      'Aula do dia: ${_formatDate(disciplina.data.documents[i].data['data'].seconds)}',
                    ));
                  });
            }));
  }

  String _formatDate(seconds) {
    var dia =
        DateTime.fromMillisecondsSinceEpoch(seconds * 1000).day.toString();
    if (int.parse(dia) < 10) dia = '0$dia';
    var mes =
        DateTime.fromMillisecondsSinceEpoch(seconds * 1000).month.toString();
    if (int.parse(mes) < 10) mes = '0$mes';
    var ano =
        DateTime.fromMillisecondsSinceEpoch(seconds * 1000).year.toString();
    return '$dia/$mes/$ano';
  }
}
