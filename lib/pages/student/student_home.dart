import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freq_ufla/pages/student/class.dart';

class StudentHome extends StatefulWidget {
  StudentHome({Key key, this.registrationNumber, this.logoutCallback})
      : super(key: key);

  final VoidCallback logoutCallback;
  final String registrationNumber;

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StudentHome"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: widget.logoutCallback,
          ),
        ],
      ),
      body: _buildStreamBuilder(context),
    );
  }

  Widget _buildStreamBuilder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('periodos')
          .document('2020-1')
          .collection('disciplinas')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('periodos')
          .document('2020-1')
          .collection('disciplinas')
          .document(data.documentID)
          .collection('turmas')
          .document('10A')
          .collection('alunos')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );
        if (snapshot.data.documents.any(
            (element) => element.documentID == widget.registrationNumber)) {
          int faltas = 0;
          return Padding(
            key: ValueKey(data.documentID),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ListTile(
                  title: Text(
                    "${data.documentID} - ${data.data["nome"]}",
                  ),
                  subtitle: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('periodos')
                          .document('2020-1')
                          .collection('disciplinas')
                          .document(data.documentID)
                          .collection('turmas')
                          .document('10A')
                          .collection('aulas')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        faltas = snapshot.data.documents
                            .where((element) =>
                                element.data["chamada"]
                                    [widget.registrationNumber] ==
                                false)
                            .length;
                        return Text("Quantidade de faltas: $faltas");
                      }),
                  onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClassHome(
                                  key: Key(data.documentID),
                                  registrationNumber: widget.registrationNumber,
                                  codClass: data.documentID)),
                        ),
                      }),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
