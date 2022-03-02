import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'DetailTodo.dart';

class TodoMain extends StatefulWidget {
  const TodoMain({Key? key}) : super(key: key);

  @override
  State<TodoMain> createState() => _TodoMainState();
}

class _TodoMainState extends State<TodoMain> {
  final TextEditingController _titleControl = TextEditingController();
  final TextEditingController _bodyControl = TextEditingController();
  final TextEditingController _typeControl = TextEditingController();

  final CollectionReference todo =
      FirebaseFirestore.instance.collection('Todo');

  Future<void> createTodo([DocumentSnapshot? documentSnapshot]) async {
    String action = 'add';

    if (documentSnapshot != null) {
      action = 'update';
      _titleControl.text = documentSnapshot['title'];
      _bodyControl.text = documentSnapshot['body'];
      _typeControl.text = documentSnapshot['type'];
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
                TextField(
                  controller: _typeControl,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    child: Text(action == 'add' ? 'add' : 'update'),
                    onPressed: () async {
                      final String? title = _titleControl.text;
                      final String? body = _bodyControl.text;
                      final String? type = _typeControl.text;

                      if (title != null && body != null) {
                        if (action == 'add') {
                          await todo.add(
                              {"title": title, "body": body, "type": type});
                        }
                        if (action == 'update') {
                          await todo
                              .doc(documentSnapshot!.id)
                              .update({"title": title, "body": body});
                        }
                        _titleControl.text = '';
                        _bodyControl.text = '';
                        _typeControl.text = '';

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
            stream: FirebaseFirestore.instance
                .collection('Todo')
                .where('type', isEqualTo: 'todo')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return FocusedMenuHolder(
                        menuWidth: MediaQuery.of(context).size.width * 0.50,
                        blurSize: 5.0,
                        menuItemExtent: 45,
                        menuBoxDecoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        duration: Duration(milliseconds: 100),
                        animateMenuItems: true,
                        blurBackgroundColor: Colors.black54,
                        openWithTap:
                            true, // Open Focused-Menu on Tap rather than Long Press
                        menuOffset:
                            10.0, // Offset value to show menuItem from the selected item
                        bottomOffsetHeight: 80.0,

                        menuItems: [
                          FocusedMenuItem(
                              title: Text("Open"),
                              trailingIcon: Icon(Icons.open_in_new),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailTodo(
                                        documentSnapshot['title'],
                                        documentSnapshot['body'],
                                      ),
                                    ));
                              }),
                          FocusedMenuItem(
                              title: Text("Edit"),
                              trailingIcon: Icon(Icons.edit),
                              onPressed: () {
                                createTodo(documentSnapshot);
                              }),
                          FocusedMenuItem(
                              title: Text("Doing"),
                              trailingIcon: Icon(Icons.work),
                              onPressed: () {
                                if (documentSnapshot['type'] == 'todo') {
                                  todo
                                      .doc(documentSnapshot.id)
                                      .update({"type": 'doing'});
                                }
                              }),
                          FocusedMenuItem(
                              title: Text(
                                "Delete",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              trailingIcon: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                _deleteTodo(documentSnapshot.id);
                              }),
                        ],
                        onPressed: () {},
                        child: Card(
                          margin: EdgeInsets.all(30),
                          shadowColor: Colors.blue,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.blue, width: 0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 5,
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
