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
        _tabs[0] = _build_vps_tab();
        _tabs[1] = build_stats_tab();
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

  /*
  **  Build VPS tab
  */
  Widget _build_vps_tab() {
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

  /*
  **  Build statistics tab
  */
  Widget build_stats_tab() {
    final List<String> labels = <String>[
      '下行字节数',
      '上行字节数',
      '下行包数',
      '上行包数',
      '下行速率(字节/秒)',
      '上行速率(字节/秒)',
      '下行速率(包/秒)',
      '上行速率(包/秒)',
      '总流量(字节)',
      '剩余流量(字节)',
      '流量起始日期',
      '流量结束日期',
      '外网地址',
      '有线MAC',
      '无线MAC',
      '客户编号',
    ];
    final List<String> values = <String>['100', '200', '300.123'];

    return (ListView.separated(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 8.0,
        right: 8.0,
      ),
      itemCount: labels.length,
      itemBuilder: (BuildContext context, int index) {
        var bg = index.isEven ? Colors.green[100] : Colors.amber[100];
        return Container(
          color: bg,
          child: Row(children: <Widget>[
            Flexible(
              flex: 8,
              fit: FlexFit.tight,
              child: Text(
                labels[index] + " :",
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(flex: 1),
            Flexible(
              flex: 11,
              fit: FlexFit.tight,
              child: Text(
                values[index],
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Text(
                units[index],
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
            height: 6.0,
          ),
    ));
    /*
    return (Column(children: <Widget>[
      Row(children: <Widget>[
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Text('Name', textAlign: TextAlign.end),
        ),
        Spacer(flex: 1),
        Flexible(
          flex: 5,
          fit: FlexFit.tight,
          child: Text('Value', textAlign: TextAlign.start),
        ),
      ]),
      Row(children: <Widget>[
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Text('Name2', textAlign: TextAlign.end),
        ),
        Spacer(flex: 1),
        Flexible(
          flex: 5,
          fit: FlexFit.tight,
          child: Text('Value2', textAlign: TextAlign.start),
        ),
      ]),
    ]));*/
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
