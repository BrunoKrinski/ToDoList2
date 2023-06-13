import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const todoListKey = 'todo_list';

class TodoController {

  late SharedPreferences sharedPreferences;

  Future<List<Map<String, dynamic>>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = jsonDecode(jsonString);
    return jsonDecoded.map((e) => e as Map<String, dynamic>).toList();
  }

  void saveTodoList(List<Map<String, dynamic>> todos) {
    final String jsonString = jsonEncode(todos);
    sharedPreferences.setString(todoListKey, jsonString);
  }
}