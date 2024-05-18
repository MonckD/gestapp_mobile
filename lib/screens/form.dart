import 'package:flutter/material.dart';
import 'package:gestapp/screens/login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show basename;
import 'package:async/async.dart';

class UserFormPage extends StatefulWidget {
  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  File? _image;
  String _selectedLit = 'A'; // Default value
  final picker = ImagePicker();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mdpController = TextEditingController();
  final TextEditingController _batimentController = TextEditingController();
  final TextEditingController _palierController = TextEditingController();
  final TextEditingController _chambreController = TextEditingController();

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
      print('No image selected');
      return;
    }

    final uri = Uri.parse('http://192.168.1.82:8888/gestapp/register.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['nom'] = _nomController.text;
    request.fields['prenom'] = _prenomController.text;
    request.fields['email'] = _emailController.text;
    request.fields['batiment'] = _batimentController.text;
    request.fields['palier'] = _palierController.text;
    request.fields['chambre'] = _chambreController.text;
    request.fields['lit'] = _selectedLit;
    request.fields['mdp'] = _mdpController.text;

    final stream = http.ByteStream(DelegatingStream.typed(_image!.openRead()));
    final length = await _image!.length();
    final multipartFile = http.MultipartFile('photo', stream, length, filename: basename(_image!.path));

    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('User created successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
    } else {
      print('Failed to create user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire Utilisateur'),
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
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.purple,
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              _image!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            width: 100,
                            height: 100,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                buildTextField('Nom', _nomController, TextInputType.text),
                SizedBox(height: 16),
                buildTextField('Prénom', _prenomController, TextInputType.text),
                SizedBox(height: 16,),
                buildTextField('Email', _emailController, TextInputType.emailAddress),
                SizedBox(height: 16),
                buildTextField('Mot de passe', _mdpController, TextInputType.visiblePassword, obscureText: true),
                SizedBox(height: 16),
                buildTextField('Bâtiment', _batimentController, TextInputType.text),
                SizedBox(height: 16),
                buildTextField('Palier', _palierController, TextInputType.text),
                SizedBox(height: 16),
                buildTextField('Chambre', _chambreController, TextInputType.text),
                SizedBox(height: 16),
                buildDropdownField('Lit', ['A', 'B'], _selectedLit, (value) {
                  setState(() {
                    _selectedLit = value!;
                  });
                }),
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

  Widget buildTextField(String labelText, TextEditingController controller, TextInputType keyboardType, {bool obscureText = false}) {
    return TextField(
      controller: controller,
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
    );
  }

  Widget buildDropdownField(String labelText, List<String> items, String selectedItem, ValueChanged<String?> onChanged) {
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