import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfessorHome extends StatefulWidget {
  ProfessorHome({Key key, this.userId, this.logoutCallback}) : super(key: key);

  final VoidCallback logoutCallback;
  final String userId;

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
          .document('2020-1')
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
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> disciplina) {
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
                    return ListTile(
                      title: Text(
                          '${disciplina.data.documents[i].documentID} - ${disciplina.data.documents[i].data['nome']}'),
                      onTap: () => {
                        Navigator.of(context)
                            .pushNamed('/professor/disciplina', arguments: [
                          disciplina.data.documents[i].documentID,
                          disciplina.data.documents[i].data['nome']
                        ])
                      },
                    );
                  });
            }));
  }
}
