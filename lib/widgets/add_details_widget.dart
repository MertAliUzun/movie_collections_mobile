import 'package:flutter/material.dart';

class AddDetailsWidget extends StatelessWidget {
  final Function(String) onAddGenre;
  final Function(String) onAddActor;
  final Function(String) onAddWriter;
  final Function(String) onAddProductionCompany;
  final Function(String) onEditDirector;

  const AddDetailsWidget({
    Key? key,
    required this.onAddGenre,
    required this.onAddActor,
    required this.onAddWriter,
    required this.onAddProductionCompany,
    required this.onEditDirector,
  }) : super(key: key);

  Future<void> _showAddDialog(BuildContext context, String title, Function(String) onAdd) async {
    String input = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: 'Enter name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input);
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value.isNotEmpty) {
        onAdd(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => _showAddDialog(context, 'Add Genre', onAddGenre),
          child: const Text('Add Genre', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _showAddDialog(context, 'Add Actor', onAddActor),
          child: const Text('Add Actor', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _showAddDialog(context, 'Add Writer', onAddWriter),
          child: const Text('Add Writer', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _showAddDialog(context, 'Add Production Company', onAddProductionCompany),
          child: const Text('Add Production Company', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _showAddDialog(context, 'Edit Director', onEditDirector),
          child: const Text('Edit Director', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
} 