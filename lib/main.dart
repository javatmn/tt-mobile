import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: HomePage()));

enum Protocols { UDP, TCP, NONE }

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
  final String URL_SWITCH_SERVER = "http://javatmn.us.to:1236/switch_server";
  final blueTxtStyle = TextStyle(color: Colors.blueAccent);
  final iconMoreVert = Icon(Icons.more_vert);
  final iconFwd = Icon(Icons.arrow_forward);

  List _serverList;
  String _protocol = 'udp';
  int _selectedTab = 0;

  List<Widget> _tabs = <Widget>[
    Text(
      'Connecting to the BOX, please wait...',
    ),
    Text(
      'Index 1: TODO Stats',
    ),
    Text(
      'Index 2: TODO Settings',
    ),
  ];

  void _setProtocol(String value) => setState(() => _protocol = value);

  void _setSelectedTab(int index) => setState(() => _selectedTab = index);

  void _setServerList(List list) => setState(() {
        _serverList = list;
        _tabs[0] = _buildVpsTab();
      });

  /*
  **  Get server list using REST API
  */
  Future<int> get_server_list() async {
    var response;

    try {
      response = await http.get(Uri.encodeFull(URL_GET_SERVER_LIST),
          headers: {"Accept": "application/json"});
    } catch (e) {
      print(e);
      /*
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Box connection fail'),
        duration: Duration(seconds: 3),
      ),);*/
      _serverList = null;
      return 1;
    }

    print(response.body);
    _setServerList(json.decode(response.body));

    return 0;
  }

  /*
  **  switch server using REST API
  */
  Future<int> switch_server(server) async {
    var req = {
      "ip": server['ip'],
      "port": server['port'],
      "lmsPort": server['lmsPort'],
      "protocol": _protocol,
    };
    var response;

    try {
      response = await http.post(Uri.encodeFull(URL_SWITCH_SERVER),
          body: json.encode(req));
    } catch (e) {
      print(e);
      return 1;
    }

    print(response.body);
    return 0;
  }

  /*
  **  switch server dialog
  */
  Future<void> switch_server_dialog(server) async {
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
                  style: blueTxtStyle,
                ),
                subtitle: Text('推荐'),
                onTap: () {
                  Navigator.pop(context, Protocols.UDP);
                },
                trailing: iconFwd,
              ),
              ListTile(
                leading: Icon(
                  Icons.title,
                  color: Colors.green,
                  size: 48.0,
                ),
                title: Text(
                  'TCP模式',
                  style: blueTxtStyle,
                ),
                subtitle: Text('推荐UDP无效时使用'),
                onTap: () {
                  Navigator.pop(context, Protocols.TCP);
                },
                trailing: iconFwd,
              ),
              ListTile(
                leading: Icon(
                  Icons.clear,
                  color: Colors.red,
                  size: 48.0,
                ),
                title: Text(
                  '取消',
                  style: blueTxtStyle,
                ),
                onTap: () {
                  Navigator.pop(context, Protocols.NONE);
                },
                trailing: iconFwd,
              ),
            ],
          );
        })) {
      case Protocols.UDP:
        _setProtocol('udp');
        break;
      case Protocols.TCP:
        _setProtocol('tcp');
        break;
      case Protocols.NONE:
        return;
        break;
      default:
        return;
    }
    print(_protocol);
    switch_server(server);
  }

  Widget _buildVpsTab() {
    return ListView.builder(
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
                      title: Text(server['ip'] + '  -  ' + server['location']),
                      subtitle:
                          Text('Clients: ' + server['clients'].toString()),
                      trailing: Icon(Icons.more_vert),
                      onTap: () {
                        switch_server_dialog(server);
                      },
                      selected: server['active'] == true,
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TBox VPN Controller"),
      ),
      body: _tabs.elementAt(_selectedTab),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('VPS'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            title: Text('Stats'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
        currentIndex: _selectedTab,
        selectedItemColor: Colors.amber[800],
        onTap: _setSelectedTab,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this.get_server_list();
  }
}
