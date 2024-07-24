import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  var _enterdTitle = '';
  var _enterdDiscription = '';
  DateTime _enterdDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _enterdDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _enterdDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: form,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  _enterdTitle = newValue!;
                },
                maxLength: 100,
                decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLength: 200,
                
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enterdDiscription = newValue!;
                },
                decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    
                    child: TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().isEmpty) {
                          return "Please select a date";
                        }
                        return null;
                      },
                      controller: _dateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        labelText: "Select Date",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        form.currentState!.reset();
                        _dateController.clear();
                      },
                      child: Text("Reset")),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (form.currentState!.validate()) {
                        form.currentState!.save();
                        final response = await http.post(
                          Uri.parse(
                              "https://todo-list-711d5-default-rtdb.firebaseio.com/list.json"),
                          headers: {"Content-Type": "application/json"},
                          body: json.encode({
                            "Title": _enterdTitle,
                            "Description": _enterdDiscription,
                            "Date": _enterdDate
                                .toIso8601String(), // Store date in ISO 8601 format
                          }),
                        );
                        if (response.statusCode == 200) {
                          Navigator.of(context).pop();
                        } else {
                          log('Failed to post data');
                        }
                      }
                    },
                    child: Text("Add"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
