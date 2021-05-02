import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'crypto.dart';
import 'model.dart';

final discoveryCmd = encrypt('{"system":{"get_sysinfo":{}}}');
final energyUsageCmd = encryptWithHeader('{"emeter":{"get_realtime":{}}}');


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

Future<EnergyUsage> readEnergyUsage(Device d) async {
  var conn = await Socket.connect(d.address.address, DEVICE_PORT);
  conn.add(energyUsageCmd);
  await conn.flush();

  var buf = new BytesBuilder();
  var packet = await conn.first;
  var expected_length = ByteData.sublistView(packet).getUint32(0, Endian.big);
  buf.add(packet.sublist(4));
  var readLength = packet.lengthInBytes - 4;
  while (readLength < expected_length) {
    packet = await conn.first;
    buf.add(packet);
  }
  await conn.close();
  var decrypted = decrypt(buf.toBytes().toList());
  return EnergyUsage.fromJson(decrypted);
}

