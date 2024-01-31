import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListViewPage extends StatefulWidget {
  final String collectionName;

  ListViewPage(this.collectionName);

  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E31F7),
        title: Text(widget.collectionName),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7E31F7),
        onPressed: () {
          _showAddItemBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(widget.collectionName)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            var items = snapshot.data!.docs;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 233, 219, 255),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text('${item['quantity']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditItemBottomSheet(
                                context,
                                item.reference,
                                item['name'],
                                item['quantity'],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteItem(item.reference);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddItemBottomSheet(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            top: 30,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Item',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFF7E31F7)),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Color(0xFF7E31F7)),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _addItem(nameController.text, quantityController.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemBottomSheet(BuildContext context,
      DocumentReference reference, String currentName, String currentQuantity) {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    TextEditingController quantityController =
        TextEditingController(text: currentQuantity);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            top: 30,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Item',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFF7E31F7)),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Color(0xFF7E31F7)),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _editItem(
                    reference, nameController.text, quantityController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            Divider(
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(String name, String quantity) async {
    await FirebaseFirestore.instance.collection(widget.collectionName).add({
      'name': name,
      'quantity': quantity,
    });
  }

  void _deleteItem(DocumentReference reference) {
    reference.delete();
  }

  void _editItem(
      DocumentReference reference, String newName, String newQuantity) {
    reference.update({
      'name': newName,
      'quantity': newQuantity,
    });
  }
}
