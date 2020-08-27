import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfessorDisciplina extends StatefulWidget {
  @override
  _ProfessorDisciplinaState createState() => _ProfessorDisciplinaState();
}

class _ProfessorDisciplinaState extends State<ProfessorDisciplina> {
  List<String> _turmas = new List<String>();
  String _disciplinaName;
  List _disc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _disc = ModalRoute.of(context).settings.arguments;

    //_disc[0] -> documentID, logo código da disciplina
    //_disc[1] -> nome da disciplina
    //_disc[2] -> array com as turmas turmas

    _disciplinaName = _disc[1];

    _disc[2].forEach((element) {
      print(element);
      setState(() => {_turmas.add(element.toString())});
      print(_turmas.length);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_turmas.length > 0) {
      return DefaultTabController(
        length: _turmas.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_disciplinaName),
            bottom: _turmas.length > 3
                ? TabBar(
                    isScrollable: true,
                    tabs: List<Widget>.generate(
                        _turmas.length,
                        (index) => Container(
                            width: MediaQuery.of(context).size.width /
                                _turmas.length,
                            child: Tab(text: _turmas[index]))),
                  )
                : TabBar(
                    tabs: List<Widget>.generate(
                        _turmas.length, (index) => Tab(text: _turmas[index])),
                  ),
          ),
          body: TabBarView(
              children: List<Widget>.generate(_turmas.length,
                  (index) => _buildStreamBuilder(context, _turmas[index]))),
          floatingActionButton:
              FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
        ),
      );
    } else {
      return Container(
          child: Scaffold(
        appBar: AppBar(
          title: Text(_disciplinaName),
        ),
        body: Center(child: CircularProgressIndicator()),
      ));
    }
  }

  Widget _buildStreamBuilder(context, turma) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('periodos')
            .document('2020-1')
            .collection('disciplinas')
            .document(_disc[0])
            .collection('turmas')
            .document(turma)
            .collection('aulas')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> aula) {
          if (aula.hasError) {
            return Center(child: Text('Error: ${aula.error}'));
          }

          if (aula.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (aula.data.documents.length == 0) {
            return Center(child: Text('Nenhuma aula cadastrada.'));
          }

          return ListView.builder(
              itemCount: aula.data.documents.length,
              itemBuilder: (BuildContext context, int i) {
                return Padding(
                    key: ValueKey(aula.data.documents[i].documentID),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ListTile(
                          title: Text(
                              'Aula do dia: ${_formatDate(aula.data.documents[i].data['data'].seconds)}'),
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
