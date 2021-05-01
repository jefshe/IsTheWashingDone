import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'crypto.dart';
import 'model.dart';

final discoveryCmd = encrypt('{"system":{"get_sysinfo":{}}}');
final energyUsageCmd = encrypt('{"emeter":{"get_realtime":{}}}');

final broadcastAddr = new InternetAddress('255.255.255.255');
const DEVICE_PORT = 9999;

Future<List<Device>> findDevices(Duration timeout) async {
  var udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  udpSocket.broadcastEnabled = true;
  udpSocket.send(discoveryCmd, broadcastAddr, DEVICE_PORT);
  List<Device> devices = [];

  var subscription = udpSocket.listen((event) {
    if (event == RawSocketEvent.read) {
      Datagram dg = udpSocket.receive();
      if (dg != null) {
        devices.add(Device.fromDatagram(dg));
      }
    }
  });
  await Future.delayed(timeout);
  subscription.cancel();
  udpSocket.close();
  return devices;
}

Stream<EnergyUsage> getUsageRealtime(Device d) async* {
  var conn = await Socket.connect(d.address.address, DEVICE_PORT);
  print('got socket: ${conn}');
  conn.add(energyUsageCmd);
  conn.listen((Uint8List data) {
    print('got packet');
    print(data);
    print(decrypt(data));
  });
  yield null;
  conn.close();
  // Stream<EnergyUsage>.periodic(Duration(seconds: 3), (x) => x).take(15);
}