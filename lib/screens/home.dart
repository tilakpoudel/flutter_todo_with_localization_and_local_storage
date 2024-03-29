import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import '../models/todos.dart';
import '../widgets/todo_item.dart';
import '../constants/colors.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoList = ToDo.todoList();
  List<ToDo> _filteredToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    _filteredToDo = todoList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 40, bottom: 20),
                        child: const LocaleText(
                          'all_todo',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo toDo in _filteredToDo.reversed)
                        ToDoItem(
                          todo: toDo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _confirmDelete,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 10.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: Locales.string(context, 'add_new_item'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: (() {
                      _addToDoItem(_todoController.text);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdBlue,
                      elevation: 10,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 48,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _confirmDelete(String id) {
    showDialog(
        context: context,
        builder: ((BuildContext context) {
          return AlertDialog(
            title: const LocaleText('confirm_delete'),
            content: const LocaleText('confirm_description'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 10,
                ),
                child: const LocaleText('cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const LocaleText('Confirm'),
                onPressed: () {
                  _deleteToDoItem(id);
                },
              ),
            ],
          );
        }));
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todoList.removeWhere((item) => item.id == id);
    });

    // remove confirm modal
    Navigator.pop(context);

    // snow notification
    const snackBar = SnackBar(
      content: LocaleText('task_deleted_successfully'),
      backgroundColor: Colors.green,
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _addToDoItem(String toDo) {
    if (toDo.isNotEmpty) {
      setState(() {
        todoList.add(
          ToDo(
            id: DateTime.now().millisecond.toString(),
            todoText: toDo,
          ),
        );
      });

      _todoController.clear();
      FocusScope.of(context).requestFocus(FocusNode());

      // snow notification
      const snackBar = SnackBar(
        content: LocaleText('task_added_successfully'),
        backgroundColor: Colors.green,
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];

    if (enteredKeyword.isEmpty) {
      results = todoList;
    } else {
      results = todoList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: const Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            maxHeight: 20,
            maxWidth: 25,
          ),
          border: InputBorder.none,
          hintText: Locales.string(context, 'search'),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.menu,
            color: tdBlack,
            size: 30,
          ),
          SizedBox(
            height: 60,
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/avatar.png',
              ),
            ),
          )
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          child: Container(
            margin: const EdgeInsets.only(right: 30.0),
            child: Row(
              children: [
                const Icon(
                  Icons.language,
                  color: Colors.grey,
                ),
                Text(
                  Locales.currentLocale(context)!.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // icon: const Icon(Icons.language,),
          onSelected: (String value) {
            setState(() {
              Locales.change(context, value);
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'en',
              child: Text('English'),
            ),
            const PopupMenuItem<String>(
              value: 'ne',
              child: Text('नेपाली'),
            ),
          ],
        ),
      ],
    );
  }
}
