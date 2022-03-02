import 'package:flutter/material.dart';

class DetailTodo extends StatefulWidget {
  // const DetailTodo({Key? key}) : super(key: key);

  final String title, body, due;

  DetailTodo(this.title, this.body, this.due);

  @override
  State<DetailTodo> createState() => _DetailTodoState();
}

class _DetailTodoState extends State<DetailTodo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Todo Detail page")),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(10),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 50),
            alignment: Alignment.center,
            child: Text(
              widget.title,
              style: TextStyle(fontSize: 40),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 50, left: 20, right: 10),
            alignment: Alignment.center,
            child: Text(
              widget.body,
              style: TextStyle(
                  fontSize: 27, color: Color.fromARGB(95, 19, 18, 18)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 50),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock_clock,
                  size: 30,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 50, left: 10),
                alignment: Alignment.center,
                child: Text(
                  widget.due,
                  style: TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 248, 157, 157)),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
