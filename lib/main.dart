import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:download_lineageos_demo/device.dart' show Device;
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Download LineageOS Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Device> devices;

  Future<List<Device>> getDevices() async {
    Response response =
        await http.get('https://lineageos-on-ipfs.com/ajax/devices.php');
    var devices = (json.decode(response.body) as List)
        .map((f) => Device.fromMap(f))
        .toList();
    return devices;
  }

  @override
  void initState() {
    super.initState();
    getDevices().then((onValue) => this.setState(() => devices = onValue));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              json.encode(devices),
            ),
          ],
        ),
      ),
    );
  }
}
