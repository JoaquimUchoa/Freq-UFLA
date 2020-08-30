import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freq_ufla/pages/professor/professor_aula.dart';
import 'package:intl/intl.dart';

class ProfessorDisciplina extends StatefulWidget {
  ProfessorDisciplina(
      {Key key,
      this.disciplinaNome,
      this.disciplinaCodigo,
      this.currentPeriod,
      this.turmas})
      : super(key: key);

  final String disciplinaNome;
  final String disciplinaCodigo;
  final String currentPeriod;
  final List<String> turmas;
  @override
  _ProfessorDisciplinaState createState() => _ProfessorDisciplinaState();
}

class _ProfessorDisciplinaState extends State<ProfessorDisciplina>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      length: widget.turmas.length,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.turmas.length > 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.disciplinaNome),
          bottom: widget.turmas.length > 3
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: List<Widget>.generate(
                      widget.turmas.length,
                      (index) => Container(
                          width: MediaQuery.of(context).size.width /
                              widget.turmas.length,
                          child: Tab(text: widget.turmas[index].toString()))),
                )
              : TabBar(
                  controller: _tabController,
                  tabs: List<Widget>.generate(widget.turmas.length,
                      (index) => Tab(text: widget.turmas[index].toString())),
                ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: List<Widget>.generate(
                widget.turmas.length,
                (index) => _buildStreamBuilder(
                    context, widget.turmas[index].toString()))),
        floatingActionButton: FloatingActionButton(
            onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfessorAula(
                            key: Key(widget.turmas[_tabController.index]),
                            disciplinaCodigo: widget.disciplinaCodigo,
                            currentPeriod: widget.currentPeriod,
                            turma: widget.turmas[_tabController.index],
                            aulaEdit: null,
                            aulaEditId: null)),
                  ),
                },
            child: Icon(Icons.add)),
      );
    } else {
      return Container(
          child: Scaffold(
        appBar: AppBar(
          title: Text(widget.disciplinaNome),
        ),
        body: Center(child: CircularProgressIndicator()),
      ));
    }
  }

  Widget _buildStreamBuilder(context, turma) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('periodos')
            .document(widget.currentPeriod)
            .collection('disciplinas')
            .document(widget.disciplinaCodigo)
            .collection('turmas')
            .document(turma)
            .collection('aulas')
            .orderBy('data')
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
                              'Aula de ${DateFormat("EEEE, d 'de' MMMM 'às' HH:mm", 'pt_Br').format(DateTime.parse(aula.data.documents[i].data['data'].toDate().toString()))}'),
                          onLongPress: () => {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Excluir Aula'),
                                content: Text(
                                    'Deseja realmente excluir a aula de ${DateFormat("EEEE, d 'de' MMMM", 'pt_Br').format(DateTime.parse(aula.data.documents[i].data['data'].toDate().toString()))}?'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Não'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Sim'),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await Firestore.instance
                                          .collection('periodos')
                                          .document(widget.currentPeriod)
                                          .collection('disciplinas')
                                          .document(widget.disciplinaCodigo)
                                          .collection('turmas')
                                          .document(widget
                                              .turmas[_tabController.index])
                                          .collection('aulas')
                                          .document(
                                              aula.data.documents[i].documentID)
                                          .delete();
                                    },
                                  )
                                ],
                              ),
                            )
                          },
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfessorAula(
                                      key: Key(
                                          widget.turmas[_tabController.index]),
                                      disciplinaCodigo: widget.disciplinaCodigo,
                                      currentPeriod: widget.currentPeriod,
                                      turma:
                                          widget.turmas[_tabController.index],
                                      aulaEdit: aula.data.documents[i].data,
                                      aulaEditId:
                                          aula.data.documents[i].documentID)),
                            ),
                          },
                        )));
              });
        });
  }
}
