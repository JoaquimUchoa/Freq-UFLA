import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freq_ufla/pages/professor/professor_disciplina.dart';

class ProfessorHome extends StatefulWidget {
  ProfessorHome({Key key, this.userId, this.logoutCallback, this.currentPeriod})
      : super(key: key);

  final VoidCallback logoutCallback;
  final String userId;
  final String currentPeriod;

  @override
  _ProfessorHomeState createState() => _ProfessorHomeState();
}

class _ProfessorHomeState extends State<ProfessorHome> {
  var _disciplinas;

  @override
  void initState() {
    setState(() {
      _disciplinas = Firestore.instance
          .collection('periodos')
          .document(widget.currentPeriod)
          .collection('disciplinas')
          .where('professorId', isEqualTo: widget.userId)
          .snapshots();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disciplinas'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: widget.logoutCallback,
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _disciplinas,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> disciplina) {
            if (disciplina.hasError) {
              return Center(child: Text('Error: ${disciplina.error}'));
            }

            if (disciplina.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (disciplina.data.documents.length == 0) {
              return Center(
                  child:
                      Text('Você não está cadastrado em nenhuma disciplina'));
            }

            return ListView.builder(
                itemCount: disciplina.data.documents.length,
                itemBuilder: (BuildContext context, int i) {
                  List<String> turmas = new List<String>();

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
                                '${disciplina.data.documents[i].documentID} - ${disciplina.data.documents[i].data['nome']}'),
                            onTap: () => {
                              disciplina.data.documents[i].data['turmas']
                                  .forEach((turma) {
                                setState(() => {turmas.add(turma.toString())});
                              }),
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfessorDisciplina(
                                        key: Key(disciplina
                                            .data.documents[i].documentID),
                                        disciplinaNome: disciplina
                                            .data.documents[i].data['nome'],
                                        disciplinaCodigo: disciplina
                                            .data.documents[i].documentID,
                                        currentPeriod: widget.currentPeriod,
                                        turmas: turmas)),
                              ),
                            },
                          )));
                });
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => {_loadCsv()}, child: Icon(Icons.add)),
    );
  }

  void _loadCsv() async {
    List<List<dynamic>> data = await getCsvData();

    Map<String, List<String>> turmas_disciplinas = new Map<String, List<String>>();
    var periodo;
    for (var i = 1; i < data.length; i++) {
      periodo = data[i][0].toString().replaceAll('/', '-');
      var codigo_curso = data[i][6].toString();
      var nome_disciplina = data[i][2].toString();
      var nome_curso = data[i][7].toString();
      var turma_z = data[i][8].toString() == 'Sim';
      var codigo_disciplina = data[i][1].toString();
      var turma = data[i][3].toString();
      var matricula_aluno = data[i][4].toString();
      var nome_aluno = data[i][5].toString();
      var email_aluno = data[i][9].toString();

      Map<String, dynamic> turmas;

      Firestore.instance.collection('alunos').document(matricula_aluno)
          .get()
          .then((value) =>
      {
        if (value.data == null) {
          Firestore.instance.collection('alunos')
              .document(matricula_aluno)
              .setData({
            'curso': nome_curso,
            'email': email_aluno,
            'nome': nome_aluno,
            'turmas': {periodo: {codigo_disciplina: turma}}
          })
        } else
          {
            turmas = value.data['turmas'][periodo],
            turmas[codigo_disciplina] = turma,
            Firestore.instance.collection('alunos')
                .document(matricula_aluno)
                .updateData({'turmas': turmas}),
          }
      });

      Firestore.instance.collection('periodos')
          .document(periodo)
          .collection('disciplinas')
          .document(codigo_disciplina)
          .setData({
            'nome': nome_disciplina,
            'professorId': widget.userId
          });

      if (!turmas_disciplinas.containsKey(codigo_disciplina)) {
        turmas_disciplinas[codigo_disciplina] = new List<String>();
      }
      if (!turmas_disciplinas[codigo_disciplina].contains(turma)) {
        turmas_disciplinas[codigo_disciplina].add(turma);
      }

      Firestore.instance.collection('periodos')
          .document(periodo)
          .collection('disciplinas')
          .document(codigo_disciplina)
          .collection('turmas')
          .document(turma)
          .collection('alunos')
          .document(matricula_aluno)
          .setData({
            'aluno': '/alunos/$matricula_aluno',
            'nome': nome_aluno,
            'turma_z': turma_z
          });
    }

    turmas_disciplinas.forEach((key, value) {
      Firestore.instance.collection('periodos')
          .document(periodo)
          .collection('disciplinas')
          .document(key)
          .updateData({
            'turmas': value
          });
    });
  }

  Future<List<List<dynamic>>> getCsvData() async {
    try {
      File file = await FilePicker.getFile(
          type: FileType.any);

      return await file
          .openRead()
          .transform(utf8.decoder)
          .transform(new CsvToListConverter())
          .toList();
    } catch (ex) {
      return new List<List<dynamic>>();
    }
  }
}
