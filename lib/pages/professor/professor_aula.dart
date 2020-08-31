import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ProfessorAula extends StatefulWidget {
  ProfessorAula(
      {Key key,
      this.disciplinaCodigo,
      this.currentPeriod,
      this.turma,
      this.aulaEdit,
      this.aulaEditId})
      : super(key: key);

  final String disciplinaCodigo;
  final String currentPeriod;
  final String turma;
  final Map<String, dynamic> aulaEdit;
  final String aulaEditId;

  @override
  _ProfessorAulaState createState() => _ProfessorAulaState();
}

class _ProfessorAulaState extends State<ProfessorAula> {
  List<String> _alunos = new List<String>();
  Map<String, bool> _presencas = new Map<String, bool>();
  DateTime _date;
  TimeOfDay _time;
  final Map<String, dynamic> _aula = {};
  final Map<String, bool> _chamada = {};

  //se for visualização/edição
  @override
  void initState() {
    super.initState();
    if (widget.aulaEdit != null) {
      _setValuesEdit();
    }
  }

  _setValuesEdit() {
    var dateTime = widget.aulaEdit['data'].seconds * 1000;
    //date
    _date = new DateTime.fromMillisecondsSinceEpoch(dateTime);
    //time
    _time = new TimeOfDay.fromDateTime(_date);
    //faltas
    widget.aulaEdit['chamada'].keys
        .forEach((key) =>_presencas[key] = widget.aulaEdit['chamada'][key]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lista de presença'),
          actions: <Widget>[
            IconButton(
                padding: EdgeInsets.only(right: 20.0),
                icon: Icon(Icons.check_circle),
                onPressed: () async => {
                      //create
                      _setChamada(),
                      _aula['data'] = _setDateTimeToTimestamp(_date, _time),
                      _aula['chamada'] = _chamada,
                      if (widget.aulaEditId == null)
                        {
                          if (_aula['data'] == null)
                            {
                              Toast.show(
                                  'Data e hora são obrigatórios!', context,
                                  duration: Toast.LENGTH_LONG,
                                  gravity: Toast.BOTTOM),
                            }
                          else
                            {
                              await Firestore.instance
                                  .collection('periodos')
                                  .document(widget.currentPeriod)
                                  .collection('disciplinas')
                                  .document(widget.disciplinaCodigo)
                                  .collection('turmas')
                                  .document(widget.turma)
                                  .collection('aulas')
                                  .add({
                                    'data': _aula['data'],
                                    'chamada': _aula['chamada'],
                                  })
                                  .then((value) => Navigator.pop(context))
                                  .catchError((onError) => {print(onError)})
                            }
                        }
                      //update
                      else
                        {
                          await Firestore.instance
                              .collection('periodos')
                              .document(widget.currentPeriod)
                              .collection('disciplinas')
                              .document(widget.disciplinaCodigo)
                              .collection('turmas')
                              .document(widget.turma)
                              .collection('aulas')
                              .document(widget.aulaEditId)
                              .updateData({
                                'data': _aula['data'],
                                'chamada': _aula['chamada'],
                              })
                              .then((value) => Navigator.pop(context))
                              .catchError((onError) => {print(onError)})
                        }
                    })
          ],
        ),
        body: _buildContainerClass(context));
  }

  _setChamada() {
    for (var i = 0; i < _alunos.length; i++) {
      _chamada[_alunos[i]] = _presencas[_alunos[i]];
    }
  }

  Timestamp _setDateTimeToTimestamp(DateTime date, TimeOfDay time) {
    if (date == null || time == null) {
      return null;
    }
    return Timestamp.fromDate(
        new DateTime(date.year, date.month, date.day, time.hour, time.minute));
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
            .orderBy('nome')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> alunos) {
          if (alunos.hasError) {
            return Center(child: Text('Error: ${alunos.error}'));
          }

          if (!alunos.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (alunos.data.documents.length == 0) {
            return Center(child: Text('Nenhum aluno matriculado.'));
          }

          //setando true para todas as presenças (if serve para não adicionar novos valores ao renderizar)
          if (_presencas.length == 0) {
            alunos.data.documents.forEach((element) {
              _presencas[element.documentID] = true;
            });
          }
          if (_alunos.length == 0)
            alunos.data.documents.forEach((element) {
              _alunos.add(element.documentID);
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
                        Text('Aula de:'),
                        _setDate(),
                        _setTime()
                      ])),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text('Presenças:')),
                  _listViewAlunos(alunos.data.documents)
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
                    title: Text(aluno[i]
                        .data['nome']
                        .toString()
                        .split(" ")
                        .map((str) => str[0] + str.substring(1).toLowerCase())
                        .join(" ")),
                    trailing: Switch(
                        value: _presencas[aluno[i].documentID],
                        onChanged: (s) => {
                              setState(() => {_presencas[aluno[i].documentID] = s})
                            }),
                  )));
        });
  }
}
