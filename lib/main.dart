import 'package:flutter/material.dart';
import 'package:todo_list2/views/home_views.dart';

void main(){
  runApp(TodoList());
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
