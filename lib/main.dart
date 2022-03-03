import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/DoingTodo.dart';
import 'package:todo_app/DoneTodo.dart';
import 'package:todo_app/TodoMain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo and Planner App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 1;
  final Screen = [
    DoingTodo(),
    TodoMain(),
    DoneTodo(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: 1,
          onTap: (currentIndex) => setState(() {
                this.currentIndex = currentIndex;
              }),
          items: const [
            Icon(Icons.run_circle_rounded),
            Icon(Icons.task),
            Icon(Icons.done_all)
          ]),
      /* appBar: AppBar(
        title: const Text('Todo Planner'),
        centerTitle: true,
      ), */
      body: Screen[currentIndex],
    );
  }
}
