import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(new MaterialApp(
    home: new HomePage(),
  ));
}

enum Answers { YES, NO, MAYBE }

// Create a stateful widget
class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

// Create the state for our stateful widget
class HomePageState extends State<HomePage> {
  final String url = "http://javatmn.us.to:1236/get_server_list";
  List serverList;
  bool _lights = true;
  String _value = '';

  void _setValue(String value) => setState(() => _value = value);

  // Function to get the JSON data
  Future<String> get_server_list() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    print(response.body);

    setState(() {
      serverList = json.decode(response.body);
    });

    return "Successfull";
  }

  Future _askUser() async {
    switch (await showDialog(
        context: context,
        /*it shows a popup with few options which you can select, for option we
        created enums which we can use with switch statement, in this first switch
        will wait for the user to select the option which it can use with switch cases*/
        builder: (BuildContext context) {
          return SimpleDialog(
            title: new Text('VPS切换(可能有短暂断流)'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.format_underlined, color: Colors.green),
                title: Text('UDP模式(推荐)'),
                onTap: () {
                  Navigator.pop(context, Answers.YES);
                },
              ),
              ListTile(
                leading: Icon(Icons.title, color: Colors.green),
                title: Text('TCP模式(专供某些ISP)'),
                onTap: () {
                  Navigator.pop(context, Answers.YES);
                },
              ),
              ListTile(
                leading: Icon(Icons.clear, color: Colors.red),
                title: Text('取消'),
                onTap: () {
                  Navigator.pop(context, Answers.YES);
                },
              ),
            ],
          );
        })) {
      case Answers.YES:
        _setValue('Yes');
        break;
      case Answers.NO:
        _setValue('No');
        break;
      case Answers.MAYBE:
        _setValue('Maybe');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Tbox VPN Controller"),
      ),
      // Create a Listview and load the data when available
      body: new ListView.builder(
          itemCount: serverList == null ? 0 : serverList.length,
          itemBuilder: (BuildContext context, int index) {
            var server = serverList[index];
            var color = server['active'] == true ? Colors.red : Colors.green;
            String btnText = server['active'] == true
                ? '  Change Protocol  '
                : 'Switch To This VPS';
            return new Column(
              children: <Widget>[
                new Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.computer,
                          color: color,
                        ),
                        title: Text(serverList[index]['ip'] +
                            '  -  ' +
                            server['location']),
                        subtitle:
                            Text('Clients: ' + server['clients'].toString()),
                        trailing: Icon(Icons.more_vert),
                        onTap: _askUser,
                      ),
                      /*
                      ButtonTheme.bar(
                        //height: 30,
                        // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            DropdownButton<String>(
                              value: dropdownValue,
                              onChanged: (String newValue) {
                                setState(() {
                                  dropdownValue = newValue;
                                });
                              },
                              items: <String>[
                                'UDP',
                                'TCP'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            FlatButton(
                              child: Text(btnText),
                              onPressed: () {
                                print(serverList[index]['ip']);
                              },
                            ),
                          ],
                        ),
                      ),*/
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();

    // Call the getJSONData() method when the app initializes
    this.get_server_list();
  }
}
