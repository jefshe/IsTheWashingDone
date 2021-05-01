import 'dart:io';
import 'dart:convert';
import 'crypto.dart';
import 'device.dart';

final discoveryMsgBuf = encrypt('{"system":{"get_sysinfo":{}}}');
final broadcastAddr = new InternetAddress('255.255.255.255');

Future<List<Device>> findDevices(Duration timeout) async {
  var udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  udpSocket.broadcastEnabled = true;
  udpSocket.send(discoveryMsgBuf, broadcastAddr, 9999);
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
