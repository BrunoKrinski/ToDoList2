import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:todo_list2/controllers/todo_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Map<String, dynamic>> todos = [];
  Map<String, dynamic>? removed;
  int? removedIndex;

  final TodoController todoRepository = TodoController();
  TextEditingController todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  Dismissible todoItem(Map<String, dynamic> todo) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.95, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        removed = todo;
        removedIndex = todos.indexOf(todo);
        todos.removeAt(removedIndex!);
        todoRepository.saveTodoList(todos);

        final snackBar = SnackBar(
          content: Text('To-Do ${todo['title']} removed!'),
          action: SnackBarAction(
            label: 'Undo!',
            onPressed: () {
              setState(() {
                todos.insert(removedIndex!, removed!);
                todoRepository.saveTodoList(todos);
              });
            },
          ),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: CheckboxListTile(
          value: todo['state'],
          onChanged: (newState) {
            setState(() {
              todo['state'] = newState;
            });
            todoRepository.saveTodoList(todos);
          },
          title: Text(todo['title']),
          secondary: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(
              todo['state'] ? Icons.check : Icons.error,
            ),
          ),
        ),
      ),
    );
  }

  Future refreshList() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      todos.sort((a, b) {
        if(a['state'] && !b['state']) {
          return 1;
        }
        else if(!a['state'] && b['state']) {
          return -1;
        }
        else {return 0;}
      });
      todoRepository.saveTodoList(todos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'To-Do List',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        cursorColor: Colors.blueAccent,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                            )
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                            ),

                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String todo = todoController.text;
                        bool state = false;
                        setState(() {
                          todos.add({'title': todo, 'state': state});
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        fixedSize: Size(100, 50),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  physics: const BouncingScrollPhysics(),
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad
                  },
                ),
                child: Flexible(
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (Map<String, dynamic> todo in todos) todoItem(todo)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
