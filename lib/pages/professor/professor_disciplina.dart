import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfessorDisciplina extends StatefulWidget {
  @override
  _ProfessorDisciplinaState createState() => _ProfessorDisciplinaState();
}

class _ProfessorDisciplinaState extends State<ProfessorDisciplina> {
  var _turmas;
  String _disciplinaName;
  List _disc;

  void _setTurmas(String disc) {
    setState(() {
      _turmas = Firestore.instance
          .collection('periodos')
          .document('2020-1')
          .collection('disciplinas')
          .document(disc)
          .collection('turmas')
          .snapshots();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _disc = ModalRoute.of(context).settings.arguments;
    _setTurmas(_disc[0]);
    _disciplinaName = _disc[1];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(_disciplinaName),
            bottom: TabBar(tabs: <Widget>[Tab(text: '10A'), Tab(text: '14A')]),
          ),
          body: TabBarView(
            children: [
              _buildStreamBuilder(context), //10A
              _buildStreamBuilder(context), //14A
            ],
          )),
    );
  }

  Widget _buildStreamBuilder(context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('periodos')
            .document('2020-1')
            .collection('disciplinas')
            .document(_disc[0])
            .collection('turmas')
            .document('10A')
            .collection('aulas')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> disciplina) {
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
                return Padding(
                    key: ValueKey(disciplina.data.documents[i].documentID),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ListTile(
                          title: Text(
                              'Aula do dia: ${_formatDate(disciplina.data.documents[i].data['data'].seconds)}'),
                        )));
              });
        });
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
