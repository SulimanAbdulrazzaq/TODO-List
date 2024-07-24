import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list2/new_item.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'list_model.dart';

class List extends StatefulWidget {
  const List({super.key});

  @override
  State<List> createState() => _ListState();
}

class _ListState extends State<List> {
  var _TODO_items = [];
  bool isLoading = true;

  Future<void> _loadState() async {
    try {
      final res = await http.get(
        Uri.parse(
            "https://todo-list-711d5-default-rtdb.firebaseio.com/list.json"),
      );

      if (res.statusCode == 200) {
        log('Response received successfully');
        var data = json.decode(res.body) as Map<String, dynamic>;
        log('Data parsed: $data');

        setState(() {
          _TODO_items.clear(); // Clear existing items to avoid duplication
          data.forEach((key, value) {
            if (value['Title'] != null &&
                value['Description'] != null &&
                value['Date'] != null) {
              log('Adding item: $value');
              _TODO_items.add(
                {
                  'id': key,
                  'model': ListModel(
                      title: value['Title'],
                      description: value['Description'],
                      date: DateTime.parse(value['Date'])),
                },
              );
            } else {
              log('Invalid data for key: $key');
            }
          });
        });

        log('TODO items updated: $_TODO_items');
      } else {
        log('Failed to load data');
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      final res = await http.delete(
        Uri.parse(
            "https://todo-list-711d5-default-rtdb.firebaseio.com/list/$id.json"),
      );

      if (res.statusCode == 200) {
        log('Item deleted successfully');
      } else {
        log('Failed to delete item');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "TODO-List",
            style: GoogleFonts.kalam(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(builder: (builder) => NewItem()),
              )
                  .then((_) {
                // Reload state after returning from NewItem screen
                _loadState();
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                for (var item in _TODO_items)
                  Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      setState(() {
                        _TODO_items.remove(item);
                      });

                      _deleteItem(item['id']);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${item['model'].title} Deleted")),
                      );
                    },
                    background: Container(color: Colors.red),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            item['model'].title,
                            style: GoogleFonts.kalam(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['model'].description,
                                style: GoogleFonts.kalam(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              DateFormat.yMd().format(item['model'].date),
                              style: GoogleFonts.kalam(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
