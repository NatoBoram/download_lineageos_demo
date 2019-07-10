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
import 'dart:math';
import 'dart:core';

void main() {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(MyApp());
}

String bibytes(int size) {
  var i = (log(size) / log(1024)).floor();
  return (size / pow(1024, i)).toStringAsFixed(2) +
      " " +
      ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"][i];
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

class DeviceListTile extends StatelessWidget {
  DeviceListTile({this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Device Name
      title: Text(device.device),

      // File name
      subtitle: Text(device.filename),
      isThreeLine: true,
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return DeviceBottomSheet(
              device: device,
            );
          },
        );
      },
    );
  }
}

class DeviceBottomSheet extends StatelessWidget {
  DeviceBottomSheet({this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      builder: (BuildContext buildContext) {
        return ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.phone_android),
              title: Text("Device"),
              subtitle: Text(device.device),
            ),
            ListTile(
              title: Text("Version"),
              subtitle: Text(device.version),
            ),
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text("File"),
              subtitle: RichText(
                text: TextSpan(
                  text: device.filename,
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(
                        "https://mirrorbits.lineageos.org${device.filepath}",
                      );
                    },
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.cloud_download),
              title: Text("IPFS"),
              subtitle: RichText(
                text: TextSpan(
                  text: device.ipfs,
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(
                        "https://lineageos-on-ipfs.com/ipfs/${device.ipfs}/${device.filename}",
                      );
                    },
                ),
              ),
            ),
            ListTile(
              title: Text("Size"),
              subtitle: Text(bibytes(device.size)),
            ),
            ListTile(
              title: Text("Date"),
              subtitle: Text("${device.date}"),
            )
          ],
        );
      },
      onClosing: () {},
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final devices = List<Device>();
  final filtered = List<Device>();
  final controller = TextEditingController(text: "");

  Future<List<Device>> getDevices() async {
    Response response =
        await http.get('https://lineageos-on-ipfs.com/ajax/devices.php');
    return (json.decode(response.body) as List)
        .map((f) => Device.fromMap(f))
        .toList();
  }

  void setDevices() {
    devices.clear();
    filter();

    getDevices().then((onValue) {
      devices.addAll(onValue);
      filter();
    });
  }

  @override
  void initState() {
    super.initState();
    setDevices();
  }

  filter() {
    filtered.clear();

    setState(() {
      filtered.addAll(
          devices.where((device) => device.device.contains(controller.text)));
    });
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
      body: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: "Filter",
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              suffixIcon: controller.text != ""
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        controller.clear();
                        filter();
                      },
                    )
                  : null,
            ),
            controller: controller,
            onChanged: (text) => filter(),
          ),
          Expanded(
            child: devices.length > 0
                ? ListView.builder(
                    itemBuilder: (BuildContext buildContext, int index) {
                      return DeviceListTile(
                        device: filtered[index],
                      );
                    },
                    itemCount: filtered.length,
                  )
                : Center(
                    child: Text("There's nothing there yet."),
                  ),
          ),
        ],
      ),
    );
  }
}
