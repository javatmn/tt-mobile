import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: HomePage()));

enum Answers { UDP, TCP, NONE }

/*
**  Home page
*/
class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

/*
**  Home page state
*/
class HomePageState extends State<HomePage> {
  final String URL_GET_SERVER_LIST =
      "http://javatmn.us.to:1236/get_server_list";
  final style = TextStyle(color: Colors.blueAccent);
  final iconMoreVert = Icon(Icons.more_vert);
  final iconPlay = Icon(Icons.check_box_outline_blank);
  List _serverList;
  String _protocol = 'udp';

  void _setValue(String value) => setState(() => _protocol = value);

  /*
  **  Get server list using RESTful API
  */
  Future<String> get_server_list() async {
    var response = await http.get(Uri.encodeFull(URL_GET_SERVER_LIST),
        headers: {"Accept": "application/json"});

    print(response.body);

    setState(() {
      _serverList = json.decode(response.body);
    });

    return "Successfull";
  }

  /*
  **  switch server dialog
  */
  Future<void> switch_user_dialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('VPS切换(会有短暂断流)'),
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.format_underlined,
                  color: Colors.green,
                  size: 48.0,
                ),
                title: Text(
                  'UDP模式',
                  style: style,
                ),
                subtitle: Text('推荐'),
                onTap: () {
                  Navigator.pop(context, Answers.UDP);
                },
                trailing: iconPlay,
              ),
              ListTile(
                leading: Icon(
                  Icons.title,
                  color: Colors.green,
                  size: 48.0,
                ),
                title: Text(
                  'TCP模式',
                  style: style,
                ),
                subtitle: Text('推荐UDP无效时使用'),
                onTap: () {
                  Navigator.pop(context, Answers.TCP);
                },
                trailing: iconPlay,
              ),
              ListTile(
                leading: Icon(
                  Icons.clear,
                  color: Colors.red,
                  size: 48.0,
                ),
                title: Text(
                  '取消',
                  style: style,
                ),
                onTap: () {
                  Navigator.pop(context, Answers.NONE);
                },
                trailing: iconPlay,
              ),
            ],
          );
        })) {
      case Answers.UDP:
        _setValue('udp');
        break;
      case Answers.TCP:
        _setValue('tcp');
        break;
      case Answers.NONE:
        break;
    }
    print(_protocol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TBox VPN Controller"),
      ),
      body: ListView.builder(
          itemCount: _serverList == null ? 0 : _serverList.length,
          itemBuilder: (BuildContext context, int index) {
            var server = _serverList[index];
            var color = server['active'] == true ? Colors.red : Colors.green;
            return Column(
              children: <Widget>[
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.computer,
                          color: color,
                        ),
                        title:
                            Text(server['ip'] + '  -  ' + server['location']),
                        subtitle:
                            Text('Clients: ' + server['clients'].toString()),
                        trailing: Icon(Icons.more_vert),
                        onTap: switch_user_dialog,
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
    this.get_server_list();
  }
}
