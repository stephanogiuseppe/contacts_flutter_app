import 'dart:io';

import 'package:contactsflutterapp/helpers/contact_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _registerController = TextEditingController();
  final _cardController = TextEditingController();

  final _nameFocus = FocusNode();

  Contact _editedContact;
  bool _userEdited = false;
  bool _documentCPF = true;
  MaskedTextController _documentMask = new MaskedTextController(mask: '000.000.000-00', text: '');

  @override
  void initState() {
    super.initState();

    widget.contact == null
      ? _editedContact = Contact()
      : _initFieldsForm();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text(_editedContact.name ?? "New contact"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
              return;
            }

            FocusScope.of(context).requestFocus(_nameFocus);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.indigo,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img))
                            : AssetImage("images/person.png")
                    ),
                  ),
                ),
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.camera).then((file) {
                    if (file == null) {
                      return;
                    }
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),

              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
              Row(
                children: <Widget>[
                  Text("CPF"),
                  Radio(
                    value: true,
                    groupValue: _documentCPF,
                    onChanged: (val) {
                      _documentMask.updateMask('000.000.000-00');
                      setState(() {
                        _documentCPF = true;
                      });
                    },
                  ),
                  Text("CNPJ"),
                  Radio(
                    value: false,
                    groupValue: _documentCPF,
                    onChanged: (val) {
                      _documentMask.updateMask('00.000.000/0000-00');
                      setState(() {
                        _documentCPF = false;
                      });
                    },
                  ),
                ],
              ),
              TextField(
                controller: _registerController,
                decoration: InputDecoration(labelText: "Document"),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onChanged: (text) {
                  _documentMask.updateText(text);
                  _userEdited = true;
                  _editedContact.register = _documentMask.text;
                  setState(() {
                    _registerController.text = _documentMask.text;
                    _registerController.selection = new TextSelection.fromPosition(
                        new TextPosition(offset: _registerController.text.length)
                    );
                  });
                },
              ),
              TextField(
                controller: _cardController,
                decoration: InputDecoration(labelText: "Card"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.card = text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initFieldsForm() {
    _editedContact = Contact.fromMap(widget.contact.toMap());
    _nameController.text = _editedContact.name;
    _emailController.text = _editedContact.email;
    _phoneController.text = _editedContact.phone;
    _registerController.text = _editedContact.register;
    _cardController.text = _editedContact.card;
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Discard changes"),
            content: Text("If you leave all changes will be lost"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );

      return Future.value(false);
    }

    return Future.value(true);
  }

  void _handleRadioValueChange(context) {
    print(context);
  }
}
