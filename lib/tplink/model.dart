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
  double currentA = 0;
  double voltageV = 0;
  double powerW = 0;
  double totalWh = 0;

  static EnergyUsage fromJson(String jsonStr) {
    var json = jsonDecode(jsonStr)['emeter']['get_realtime'];
    var usage = new EnergyUsage();
    usage.currentA = json['current_ma'] / 1000;
    usage.voltageV = json['voltage_mv'] / 1000;
    usage.powerW = json['power_mw'] / 1000;
    usage.totalWh = json['total_wh'];
    return usage;
  }
}
