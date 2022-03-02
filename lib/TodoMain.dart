import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'DetailTodo.dart';

class TodoMain extends StatefulWidget {
  const TodoMain({Key? key}) : super(key: key);

  @override
  State<TodoMain> createState() => _TodoMainState();
}

class _TodoMainState extends State<TodoMain> {
  final TextEditingController _titleControl = TextEditingController();
  final TextEditingController _bodyControl = TextEditingController();

  final CollectionReference todo =
      FirebaseFirestore.instance.collection('Todo');

  Future<void> createTodo([DocumentSnapshot? documentSnapshot]) async {
    String action = 'add';

    if (documentSnapshot != null) {
      action = 'update';
      _titleControl.text = documentSnapshot['title'];
      _bodyControl.text = documentSnapshot['body'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleControl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _bodyControl,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    child: Text(action == 'add' ? 'add' : 'update'),
                    onPressed: () async {
                      final String? title = _titleControl.text;
                      final String? body = _bodyControl.text;

                      if (title != null && body != null) {
                        if (action == 'add') {
                          await todo.add({"title": title, "body": body});
                        }
                        if (action == 'update') {
                          await todo
                              .doc(documentSnapshot!.id)
                              .update({"title": title, "body": body});
                        }
                        _titleControl.text = '';
                        _bodyControl.text = '';

                        Navigator.of(context).pop();
                      }
                    })
              ]);
        });
  }

  Future<void> _deleteTodo(String todoId) async {
    await todo.doc(todoId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a Todo But why????')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: todo.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return GestureDetector(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DetailTodo(
                            documentSnapshot['title'],
                            documentSnapshot['body'],
                          ),
                        )),
                        child: Card(
                          margin: EdgeInsets.all(30),
                          shadowColor: Colors.blue,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.blue, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 7,
                          child: Column(
                            children: [
                              Container(
                                height: 200,
                                child: ListTile(
                                  title: Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 30, top: 20),
                                    child: Text(
                                      documentSnapshot['title'],
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  subtitle: Text(documentSnapshot['body'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(fontSize: 25)),
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      child: GestureDetector(
                                          onTap: () =>
                                              createTodo(documentSnapshot),
                                          child: Container(
                                            width: 100,
                                            height: 30,
                                            color: Colors.blue,
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          )),
                                    ),
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteTodo(documentSnapshot.id)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => createTodo(),
          child: const Icon(Icons.add),
        ));
  }
}
