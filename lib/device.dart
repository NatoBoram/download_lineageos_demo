// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

class Device {
  String device;
  DateTime date;
  DateTime datetime;
  String filename;
  String filepath;
  String sha1;
  String sha256;
  int size;
  String type;
  String version;
  String ipfs;

  Device({
    this.device,
    this.date,
    this.datetime,
    this.filename,
    this.filepath,
    this.sha1,
    this.sha256,
    this.size,
    this.type,
    this.version,
    this.ipfs,
  });

  factory Device.fromJson(String str) => Device.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Device.fromMap(Map<String, dynamic> json) => Device(
        device: json["device"],
        date: DateTime.parse(json["date"]),
        datetime: DateTime.parse(json["datetime"]),
        filename: json["filename"],
        filepath: json["filepath"],
        sha1: json["sha1"],
        sha256: json["sha256"],
        size: json["size"],
        type: json["type"],
        version: json["version"],
        ipfs: json["ipfs"],
      );

  Map<String, dynamic> toMap() => {
        "device": device,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "datetime": datetime.toIso8601String(),
        "filename": filename,
        "filepath": filepath,
        "sha1": sha1,
        "sha256": sha256,
        "size": size,
        "type": type,
        "version": version,
        "ipfs": ipfs,
      };
}
