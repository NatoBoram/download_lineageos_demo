import 'dart:convert' show json;
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:download_lineageos_demo/device.dart' show Device;
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;
import 'package:url_launcher/url_launcher.dart' show launch;

void main() {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
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
  final List<Device> devices = List<Device>();

  Future<List<Device>> getDevices() async {
    Response response =
        await http.get('https://lineageos-on-ipfs.com/ajax/devices.php');
    return (json.decode(response.body) as List)
        .map((f) => Device.fromMap(f))
        .toList();
  }

  void setDevices() {
    setState(() => devices.clear());
    getDevices().then((onValue) => setState(() => devices.addAll(onValue)));
  }

  @override
  void initState() {
    super.initState();
    setDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: setDevices,
          )
        ],
      ),
      body: devices.length > 0
          ? ListView.builder(
              itemBuilder: (BuildContext buildContext, int index) {
                return ListTile(
                  // Device Name
                  title: Text(devices[index].device),

                  // URL
                  subtitle: RichText(
                    text: TextSpan(
                      text: devices[index].filename,
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch("https://mirrorbits.lineageos.org" +
                              devices[index].filepath);
                        },
                    ),
                  ),
                );
              },
              itemCount: devices.length,
            )
          : Center(
              child: Text("There's nothing there yet."),
            ),
    );
  }
}
