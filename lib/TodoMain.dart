import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class TodoMain extends StatefulWidget {
  const TodoMain({Key? key}) : super(key: key);

  @override
  State<TodoMain> createState() => _TodoMainState();
}

class _TodoMainState extends State<TodoMain> {
  final TextEditingController _titleControl = TextEditingController();
  final TextEditingController _bodyControl = TextEditingController();
  final TextEditingController _typeControl = TextEditingController();
  final TextEditingController _dueControl = TextEditingController();

  final CollectionReference todo =
      FirebaseFirestore.instance.collection('Todo');

  Future<void> createTodo([DocumentSnapshot? documentSnapshot]) async {
    String action = 'add';

    if (documentSnapshot != null) {
      action = 'update';
      _titleControl.text = documentSnapshot['title'];
      _bodyControl.text = documentSnapshot['body'];
      _typeControl.text = documentSnapshot['type'];
      _dueControl.text = documentSnapshot['due'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
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
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _dueControl,
                  decoration: const InputDecoration(labelText: 'Due Date'),
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
                      final String? due = _dueControl.text;

                      if (title != null && body != null) {
                        if (action == 'add') {
                          await todo.add({
                            "title": title,
                            "body": body,
                            "type": type,
                            "due": due
                          });
                        }
                        if (action == 'update') {
                          await todo
                              .doc(documentSnapshot!.id)
                              .update({"title": title, "body": body});
                        }
                        _titleControl.text = '';
                        _bodyControl.text = '';
                        _typeControl.text = '';
                        _dueControl.text = '';

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
      body: Container(
        child: SingleChildScrollView(
          child: ColumnSuper(
            innerDistance: -30.0,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: 280,
                  color: Colors.blue,
                  child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 40)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: const Text(
                              'HI',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          Text(
                            'Todo Planner',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          Icon(
                            Icons.notifications_active,
                            color: Colors.white,
                            size: 40,
                          )
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 50)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                              Text('Here\'s Update Today.',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                          const Icon(
                            Icons.access_time_filled_outlined,
                            color: Colors.white,
                            size: 50,
                          )
                        ],
                      ),
                    ],
                  )),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(90),
                        topRight: Radius.circular(90))),
                height: MediaQuery.of(context).size.height / 1.5,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Todo')
                        .where('type', isEqualTo: 'todo')
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: streamSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot documentSnapshot =
                                  streamSnapshot.data!.docs[index];

                              return FocusedMenuHolder(
                                menuWidth:
                                    MediaQuery.of(context).size.width * 0.50,
                                blurSize: 5.0,
                                menuItemExtent: 45,
                                menuBoxDecoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.0))),
                                duration: const Duration(milliseconds: 100),
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 180),
                                                      child: const Icon(
                                                        Icons.horizontal_rule,
                                                        size: 50,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: Text(
                                                        documentSnapshot[
                                                            'title'],
                                                        style: TextStyle(
                                                            fontSize: 40,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: Text(
                                                          documentSnapshot[
                                                              'body'],
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(15),
                                                            child: Icon(
                                                                Icons.watch,
                                                                size: 30)),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Text(
                                                              documentSnapshot[
                                                                  'due'],
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Text(
                                                              'Action type : ',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Text(
                                                              documentSnapshot[
                                                                  'type'],
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white)),
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
                                      title: Text("Doing"),
                                      trailingIcon: Icon(Icons.work),
                                      onPressed: () {
                                        if (documentSnapshot['type'] ==
                                            'todo') {
                                          todo
                                              .doc(documentSnapshot.id)
                                              .update({"type": 'doing'});
                                        }
                                      }),
                                  FocusedMenuItem(
                                      title: const Text(
                                        "Delete",
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                      trailingIcon: const Icon(
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
                                  shadowColor: Colors.black,
                                  color: Color.fromARGB(255, 215, 242, 255),
                                  shape: RoundedRectangleBorder(
                                    /* side: const BorderSide(
                                        color: Colors.black, width: 1.5), */
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  elevation: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: 220,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  documentSnapshot['title'],
                                                  style: const TextStyle(
                                                      fontSize: 35,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const Divider(),
                                              Container(
                                                margin: EdgeInsets.all(10),
                                                child: Text(
                                                    documentSnapshot['body'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    )),
                                              ),
                                              const Divider(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createTodo(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
