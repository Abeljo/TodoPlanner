import 'package:flutter/material.dart';

class DetailTodo extends StatefulWidget {
  // const DetailTodo({Key? key}) : super(key: key);

  final String title, body;

  DetailTodo(this.title, this.body);

  @override
  State<DetailTodo> createState() => _DetailTodoState();
}

class _DetailTodoState extends State<DetailTodo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.all(40),
          ),
          Text(
            "Todo Detail page",
            style: TextStyle(fontSize: 30),
          ),
          Text(
            widget.title,
            style: TextStyle(fontSize: 40),
          ),
          Text(
            widget.body,
            style: TextStyle(fontSize: 20),
          )
        ]),
      ),
    );
  }
}
