import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClassHome extends StatefulWidget {
  ClassHome({Key key, this.registrationNumber, this.codClass})
      : super(key: key);

  final String codClass;
  final String registrationNumber;

  @override
  _ClassState createState() => _ClassState();
}

class _ClassState extends State<ClassHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.codClass),
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
          .document(widget.codClass)
          .collection('turmas')
          .document('10A')
          .collection('aulas')
          .orderBy("data", descending: true)
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
    debugPrint(data.data.toString());
    debugPrint(data.documentID);
    return Padding(
      key: ValueKey(data.documentID),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
            color: data.data["chamada"][widget.registrationNumber]
                ? Colors.greenAccent
                : Color(0xFFEF8F73)),
        child: ListTile(
          title: Text(
            "${DateFormat("EEEE, d 'de' MMMM 'às' HH:mm", 'pt_Br').format(DateTime.parse(data.data["data"].toDate().toString()))}",
          ),
          subtitle: data.data["chamada"][widget.registrationNumber]
              ? Text("Presente")
              : Text("Ausente"),
        ),
      ),
    );
  }
}
