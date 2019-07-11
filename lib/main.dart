import 'dart:convert' show json;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:download_lineageos_demo/device.dart' show Device;
import 'package:flutter/services.dart';
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
  DeviceListTile({
    @required this.device,
  });

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

class ListTileURL extends StatelessWidget {
  ListTileURL({
    @required this.leading,
    @required this.title,
    @required this.text,
    @required this.url,
    @required this.onLongPress,
  });

  final Widget leading;
  final Widget title;
  final String text;
  final String url;
  final void Function() onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(color: Colors.blue),
        ),
      ),
      isThreeLine: true,
      onTap: () => launch(url),
      onLongPress: onLongPress,
    );
  }
}

class DeviceBottomSheet extends StatelessWidget {
  DeviceBottomSheet({
    @required this.device,
  });

  final Device device;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _onLongPress(GlobalKey<ScaffoldState> _scaffoldKey, String text) {
    Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        "Copied : $text",
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      builder: (BuildContext context) {
        return Scaffold(
          key: _scaffoldKey,
          body: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.phone_android),
                title: Text("Device"),
                subtitle: Text(device.device),
                onLongPress: () => _onLongPress(_scaffoldKey, device.device),
              ),
              ListTile(
                title: Text("Version"),
                subtitle: Text(device.version),
                onLongPress: () => _onLongPress(_scaffoldKey, device.version),
              ),
              ListTileURL(
                leading: Icon(Icons.file_download),
                title: Text("File"),
                text: device.filename,
                url: "https://mirrorbits.lineageos.org${device.filepath}",
                onLongPress: () => _onLongPress(_scaffoldKey,
                    "https://mirrorbits.lineageos.org${device.filepath}"),
              ),
              ListTileURL(
                leading: Icon(Icons.cloud_download),
                title: Text("IPFS"),
                text: device.ipfs,
                url:
                    "https://lineageos-on-ipfs.com/ipfs/${device.ipfs}/${device.filename}",
                onLongPress: () => _onLongPress(_scaffoldKey, device.ipfs),
              ),
              ListTile(
                title: Text("Size"),
                subtitle: Text(bibytes(device.size)),
                onLongPress: () =>
                    _onLongPress(_scaffoldKey, bibytes(device.size)),
              ),
              ListTile(
                title: Text("Date"),
                subtitle: Text("${device.datetime}"),
                onLongPress: () =>
                    _onLongPress(_scaffoldKey, "${device.datetime}"),
              )
            ],
          ),
        );
      },
      onClosing: () {},
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _devices = List<Device>();
  final _filtered = List<Device>();
  final _controller = TextEditingController(text: "");

  Future<List<Device>> getDevices() async {
    Response response =
        await http.get('https://lineageos-on-ipfs.com/ajax/devices.php');
    return (json.decode(response.body) as List)
        .map((f) => Device.fromMap(f))
        .toList();
  }

  void setDevices() {
    _devices.clear();
    filter();

    getDevices().then((onValue) {
      _devices.addAll(onValue);
      filter();
    });
  }

  @override
  void initState() {
    super.initState();
    setDevices();
  }

  filter() {
    _filtered.clear();

    setState(
      () => _filtered.addAll(_devices.where(
        (device) => device.device.contains(_controller.text),
      )),
    );
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
          ListTile(
            title: TextField(
              decoration: InputDecoration(
                labelText: "Filter",
              ),
              controller: _controller,
              onChanged: (text) => filter(),
            ),
            trailing: _controller.text != ""
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _controller.clear();
                      filter();
                    },
                  )
                : null,
          ),
          Expanded(
            child: _devices.length > 0
                ? ListView.builder(
                    itemBuilder: (BuildContext buildContext, int index) {
                      return DeviceListTile(
                        device: _filtered[index],
                      );
                    },
                    itemCount: _filtered.length,
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
