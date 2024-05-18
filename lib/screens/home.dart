import 'package:flutter/material.dart';
import 'package:gestapp/screens/login.dart';
import 'package:gestapp/screens/problem.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> _problems = [];
  bool _isLoading = true;
  final Box _box = Hive.box("user"); // utilisation de la boite


  @override
  void initState() {
    super.initState();
    _fetchProblems();
  }

  void logout(){
    _box.clear();
    _box.clear();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );

  }

  Future<void> _fetchProblems() async {
    final response = await http.get(Uri.parse('http://192.168.1.82:8888/gestapp/getAllProblem.php?userId=${_box.get('id')}'));

    if (response.statusCode == 200) {
      final List<dynamic> problems = json.decode(response.body);
      setState(() {
        _problems = problems;
        _isLoading = false;
      });
    } else {
      // Handle the error
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load problems')),
      );
    }
  }

  void _showProblemDetails(Map<String, dynamic> problem) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'http://192.168.1.82:8888/gestapp/${problem['photo']}',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Catégorie',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  problem['categorie'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  problem['description'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Statut',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  problem['statut'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Date de création',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  problem['create_date'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Problèmes'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _problems.length,
              itemBuilder: (context, index) {
                final problem = _problems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Image.network(
                      'http://192.168.1.82:8888/gestapp/${problem['photo']}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      problem['categorie'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(problem['description']),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          problem['create_date'].split(' ')[0], // Date
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          problem['create_date'].split(' ')[1], // Time
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () => _showProblemDetails(problem),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle button press
                Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProblemeFormPage(),
        ),
      );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}