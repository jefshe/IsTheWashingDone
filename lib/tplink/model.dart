import 'dart:convert';
import 'dart:io';
import 'crypto.dart';

class Device {
  InternetAddress _address;
  String _name;
  Device._();

  get name => _name;
  get address => _address;

  static Device fromDatagram(Datagram dg)  {
    var device = new Device._();
    device._address = dg.address;
    print(decrypt(dg.data));
    var json = jsonDecode(decrypt(dg.data));
    var sysInfo = json['system']['get_sysinfo'];
    device._name = sysInfo['alias'];
    return device;
  }
}

class EnergyUsage {
  int currentmA;
  int voltagemV;
  int powermW;
  int totalWh;
}
