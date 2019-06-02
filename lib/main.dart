import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(new MaterialApp(
    home: new HomePage(),
  ));
}

// Create a stateful widget
class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

// Create the state for our stateful widget
class HomePageState extends State<HomePage> {
  final String url = "http://t95mk:1236/get_server_list";
  List serverList;

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
            String btnText =
                server['active'] == true ? 'Current VPS' : 'Switch To This VPS';
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
                      ),
                      ButtonTheme.bar(
                        //height: 30,
                        // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text(btnText),
                              onPressed: server['active'] == true
                                  ? null
                                  : () {
                                      print(serverList[index]['ip']);
                                    },
                            ),
                          ],
                        ),
                      ),
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
