// main.dart
import 'package:flutter/material.dart';

import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'bmi_6206022610041',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _hightController = TextEditingController();
  
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _oldController.text = existingJournal['sex'];
      _sexController.text = existingJournal['old'];
      _weightController.text = existingJournal['weight'];
      _hightController.text = existingJournal['hight'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _oldController,
                    decoration: const InputDecoration(hintText: 'old'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _sexController,
                    decoration: const InputDecoration(hintText: 'sex'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(hintText: 'weight'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _hightController,
                    decoration: const InputDecoration(hintText: 'hight'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _oldController.text = '';
                      _sexController.text = '';
                      _weightController.text = '';
                      _hightController.text  = '';


                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {

    double height = double.parse(_hightController.text) / 100;
    double weight = double.parse(_weightController.text);

    double heightSquare = height * height;
    double results = weight / heightSquare;
    print('bmi ${results.toString()}');
    await SQLHelper.createItem(
        _nameController.text, _oldController.text,_sexController.text,_weightController.text,_hightController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    double height = double.parse(_hightController.text) / 100;
    double weight = double.parse(_weightController.text);

    double heightSquare = height * height;
    double results = weight / heightSquare;
    print('bmi ${results.toString()}');
    await SQLHelper.updateItem(
        id, _nameController.text, _oldController.text,_sexController.text,_weightController.text,_hightController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_journals[index]['name']),
                    subtitle: Text(_journals[index]['old']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_journals[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
