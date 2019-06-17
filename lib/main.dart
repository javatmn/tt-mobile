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
  static const String URL_GET_SERVER_LIST =
      "http://javatmn.us.to:1236/get_server_list";
  static const String URL_SWITCH_SERVER = "http://javatmn.us.to:1236/switch_server";
  static const String URL_GET_CLIENT_INFO = "http://javatmn.us.to:1236/get_client_info";
  final blueTxtStyle = TextStyle(color: Colors.blueAccent);
  final iconMoreVert = Icon(Icons.more_vert);
  final iconFwd = Icon(Icons.arrow_forward);
  Timer statsTimer;

  List _serverList;
  String _protocol = 'udp';
  int _selectedTab = 0;
  var _clientInfo = {
    'bytesOut': 0,
    'bytesIn': 0,
    'packetsOut': 0,
    'packetsIn': 0,
    'downRate': 0,
    'upRate': 0,
    'quota': 0,
    'remain': 0,
    'startTime': '',
    'endTime': '',
    'extIp': '',
    'eMac': '',
    'wMac': '',
    'index': '',
  };

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
      '20秒下行速率(字节/秒)',
      '20秒上行速率(字节/秒)',
      '流量配额(字节)',
      '剩余流量(字节)',
      '流量起始日期',
      '流量结束日期',
      '外网地址',
      '有线MAC',
      '无线MAC',
      '客户编号',
    ];
    List<String> values = <String>[
      _clientInfo['bytesOut'].toString(),
      _clientInfo['bytesIn'].toString(),
      _clientInfo['packetsOut'].toString(),
      _clientInfo['packetsIn'].toString(),
      _clientInfo['downRate'].toString(),
      _clientInfo['upRate'].toString(),
      _clientInfo['quota'].toString(),
      _clientInfo['remain'].toString(),
      _clientInfo['startTime'],
      _clientInfo['endTime'],
      _clientInfo['extIp'],
      _clientInfo['eMac'],
      _clientInfo['wMac'],
      _clientInfo['index'].toString(),
    ];

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
              flex: 9,
              fit: FlexFit.tight,
              child: Text(
                labels[index],
                //textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                ": ",
                //textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: Text(
                values[index],
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 14.0,
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
    statsTimer = Timer.periodic(Duration(seconds: 20), (Timer t) {
      try {
        Future<http.Response> response = http.get(Uri.encodeFull(URL_GET_CLIENT_INFO),
            headers: {"Accept": "application/json"});
        response.then((http.Response rsp){
          print(rsp.body);
          setState(() {
            _clientInfo = json.decode(rsp.body);
            _tabs[1] = build_stats_tab();
          });
        });
      } catch (e) {
        print(e);
      }
    });
  }
}
