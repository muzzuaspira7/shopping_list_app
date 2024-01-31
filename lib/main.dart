import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'listview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // primaryColor: Colors.purple,
          primarySwatch: Colors.deepPurple),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToHome();
  }

  Future<void> navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: Colors.white,
        color: const Color.fromARGB(255, 209, 181, 255),

        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_basket,
                size: 50,
                color: Color(0xFF7E31F7),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Listify',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 27,
                  fontFamily: 'LemonMilk',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> collectionNames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E31F7),
        title: const Text(
          'Listify',
          style: TextStyle(fontFamily: 'LemonMilk'),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7E31F7),
        onPressed: () {
          _showCreateCollectionBottomSheet(context);
        },
        label: const Text('Create Main Collection'),
      ),
      body: Container(
        color: Colors.purple.shade50,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: collectionNames.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListViewPage(collectionNames[index]),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  color: const Color.fromARGB(255, 233, 219, 255),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          collectionNames[index].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteConfirmationDialog(context, index);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateCollectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CreateCollectionForm(onCollectionCreated: (collectionName) {
          setState(() {
            collectionNames.add(collectionName);
          });
          Navigator.pop(context);
        });
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: const Text('Are you sure you want to delete this collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteCollection(index);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCollection(int index) async {
    String collectionName = collectionNames[index];

    // Delete documents in the collection
    QuerySnapshot documents =
        await FirebaseFirestore.instance.collection(collectionName).get();
    for (QueryDocumentSnapshot document in documents.docs) {
      await document.reference.delete();
    }

    // Delete the collection itself
    await FirebaseFirestore.instance.collection(collectionName).doc().delete();

    // Remove the collection from the list
    setState(() {
      collectionNames.removeAt(index);
    });
  }
}

class CreateCollectionForm extends StatefulWidget {
  final Function(String) onCollectionCreated;

  const CreateCollectionForm({required this.onCollectionCreated});

  @override
  _CreateCollectionFormState createState() => _CreateCollectionFormState();
}

class _CreateCollectionFormState extends State<CreateCollectionForm> {
  final TextEditingController _collectionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _collectionController,
            decoration: const InputDecoration(
                labelText: 'Main Collection Name',
                labelStyle: TextStyle(color: Color(0xFF7E31F7))),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xFF7E31F7))),
            onPressed: () {
              createMainCollection(context);
            },
            child: const Text('Create Main Collection'),
          ),
        ],
      ),
    );
  }

  void createMainCollection(BuildContext context) async {
    String collectionName = _collectionController.text;

    if (collectionName.isNotEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore
          .collection(collectionName)
          .add({'name': 'ExampleName', 'quantity': 'ExampleQuantity'});

      widget.onCollectionCreated(collectionName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Main Collection created successfully!'),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a collection name.'),
          backgroundColor: Colors.yellow,
        ),
      );
    }
  }
}
