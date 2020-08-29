import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfessorAula extends StatefulWidget {
  ProfessorAula(
      {Key key, this.disciplinaCodigo, this.currentPeriod, this.turma})
      : super(key: key);

  final String disciplinaCodigo;
  final String currentPeriod;
  final String turma;
  @override
  _ProfessorAulaState createState() => _ProfessorAulaState();
}

class _ProfessorAulaState extends State<ProfessorAula> {
  List<String> alunos = new List<String>();
  List<bool> presencas = new List<bool>();
  DateTime _date;
  TimeOfDay _time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lista de presença'),
          actions: <Widget>[
            IconButton(
                padding: EdgeInsets.only(right: 20.0),
                icon: Icon(Icons.check_circle),
                onPressed: () => {})
          ],
        ),
        body: _buildContainerClass(context));
  }

  Widget _buildContainerClass(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('periodos')
            .document(widget.currentPeriod)
            .collection('disciplinas')
            .document(widget.disciplinaCodigo)
            .collection('turmas')
            .document(widget.turma)
            .collection('alunos')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> aluno) {
          if (aluno.hasError) {
            return Center(child: Text('Error: ${aluno.error}'));
          }

          if (aluno.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (aluno.data.documents.length == 0) {
            return Center(child: Text('Nenhum aluno matriculado.'));
          }

          //setando true para todas as presenças (if serve para não adicionar novos valores ao renderizar)
          if (presencas.length == 0) {
            List.generate(
                aluno.data.documents.length, (index) => {presencas.add(true)});
          }
          if (alunos.length == 0)
            aluno.data.documents.forEach((element) {
              alunos.add(element.documentID);
            });

          return Container(
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(children: <Widget>[
                        Text('Horário da aula:'),
                        _setDate(),
                        _setTime()
                      ])),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text('Presenças:')),
                  _listViewAlunos(aluno.data.documents)
                ]),
          );
        });
  }

  Widget _setDate() {
    return Expanded(
        flex: 2,
        child: IconButton(
            icon: _date == null
                ? Icon(Icons.date_range)
                : Text(DateFormat("EEEE, d 'de' MMMM", 'pt_Br')
                    .format(_date)
                    .toString()),
            onPressed: () => {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2021))
                      .then((date) => setState(() => {_date = date})),
                }));
  }

  Widget _setTime() {
    return Expanded(
        flex: 1,
        child: IconButton(
            icon:
                _time == null ? Icon(Icons.alarm) : Text(_time.format(context)),
            onPressed: () => {
                  showTimePicker(context: context, initialTime: TimeOfDay.now())
                      .then((time) => setState(() => {_time = time})),
                }));
  }

  Widget _listViewAlunos(aluno) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: aluno.length,
        itemBuilder: (BuildContext context, int i) {
          return Padding(
              key: ValueKey(aluno[i].documentID),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ListTile(
                    title: Text(aluno[i].documentID),
                    trailing: Switch(
                        value: presencas[i],
                        onChanged: (s) => {
                              setState(() => {presencas[i] = s})
                            }),
                  )));
        });
  }
}
