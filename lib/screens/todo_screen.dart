import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:security_app/screens/settings_page.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<String> _todoItems = [];

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _todoItems.add(task);
      });
    }
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  void _promptAddTodoItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New task'),
          content: TextField(
            autofocus: true,
            onSubmitted: (value) {
              _addTodoItem(value);
              Navigator.pop(context);
            },
            decoration: const InputDecoration(
              hintText: 'Enter something to do...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addTodoItem(_taskController.text);
                _taskController.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ));
              },
              icon: const Icon(CupertinoIcons.settings))
        ],
      ),
      body: ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(_todoItems[index]),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              _removeTodoItem(index);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Task removed")));
            },
            child: ListTile(
              title: Text(_todoItems[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptAddTodoItem,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
