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
  int currentIndex = 0;
  final Screen = [
    TodoMain(),
    DoingTodo(),
    DoneTodo(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.run_circle),
            label: 'Doing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Done',
          ),
        ],
      ),
      appBar: AppBar(title: const Text('Todo Planner')),
      body: Screen[currentIndex],
    );
  }
}
