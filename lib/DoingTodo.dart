import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class DoingTodo extends StatefulWidget {
  const DoingTodo({Key? key}) : super(key: key);

  @override
  State<DoingTodo> createState() => _DoingTodoState();
}

class _DoingTodoState extends State<DoingTodo> {
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
          stream: FirebaseFirestore.instance
              .collection('Todo')
              .where('type', isEqualTo: 'doing')
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
                              showModalBottomSheet(
                                  backgroundColor: Colors.blueAccent,
                                  context: context,
                                  builder: (context) => Center(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(15),
                                            child: Text(
                                              documentSnapshot['title'],
                                              style: TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(15),
                                            child: Text(
                                                documentSnapshot['body'],
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                  margin:
                                                      const EdgeInsets.all(15),
                                                  child: Icon(Icons.watch,
                                                      size: 30)),
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(15),
                                                child: Text(
                                                    documentSnapshot['due'],
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(15),
                                                child: Text('Action type : ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(15),
                                                child: Text(
                                                    documentSnapshot['type'],
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )));
                            }),
                        FocusedMenuItem(
                            title: Text("Edit"),
                            trailingIcon: Icon(Icons.edit),
                            onPressed: () {
                              createTodo(documentSnapshot);
                            }),
                        FocusedMenuItem(
                            title: Text("Done"),
                            trailingIcon: Icon(Icons.done_all_sharp),
                            onPressed: () {
                              todo
                                  .doc(documentSnapshot.id)
                                  .update({"type": 'done'});
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
                        color: Color.fromARGB(255, 180, 231, 255),
                        shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 250,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        documentSnapshot['title'],
                                        style: const TextStyle(
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Divider(),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: Text(documentSnapshot['body'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: TextStyle(fontSize: 25)),
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.timelapse),
                                        Text('Due Date'),
                                        Text(documentSnapshot['due'])
                                      ],
                                    )
                                  ],
                                )),
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
    );
  }
}
