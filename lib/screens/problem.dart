import 'package:flutter/material.dart';
import 'package:gestapp/screens/home.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show basename;
import 'package:async/async.dart';

class ProblemeFormPage extends StatefulWidget {
  @override
  _ProblemeFormPageState createState() => _ProblemeFormPageState();
}

class _ProblemeFormPageState extends State<ProblemeFormPage> {
  File? _image;
  String _selectedCategorie = 'Menuserie'; // Default value
  final picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  final Box _box = Hive.box("user"); // utilisation de la boite

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final uri = Uri.parse('http://192.168.1.82:8888/gestapp/problem.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['description'] = _descriptionController.text;
    request.fields['categorie'] = _selectedCategorie;
    request.fields['userId'] = "${_box.get('id')}";

    final stream = http.ByteStream(DelegatingStream.typed(_image!.openRead()));
    final length = await _image!.length();
    final multipartFile = http.MultipartFile('photo', stream, length,
        filename: basename(_image!.path));

    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Problem created successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create problem')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire de Problème'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showPicker(context),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _image!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                  ),
                ),
                SizedBox(height: 16),
                buildDropdownField(
                    'Catégorie',
                    [
                      'Menuserie',
                      'Electricité',
                      'Plomberie',
                      'Maçonnerie',
                      'Autre'
                    ],
                    _selectedCategorie, (value) {
                  setState(() {
                    _selectedCategorie = value!;
                  });
                }),
                SizedBox(height: 16),
                buildTextField('Description', TextInputType.multiline,
                    maxLines: 5),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Envoyer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextInputType keyboardType,
      {bool obscureText = false, int maxLines = 1}) {
    return TextField(
      controller: labelText == 'Description' ? _descriptionController : null,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
    );
  }

  Widget buildDropdownField(String labelText, List<String> items,
      String selectedItem, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedItem,
          isDense: true,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galerie'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Caméra'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
