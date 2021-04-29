import 'dart:io';
import 'dart:convert';

final discoveryMsgBuf = encrypt('{"system":{"get_sysinfo":{}}}');
final broadcastAddr = new InternetAddress('255.255.255.255');

class Device {
  String address;
}

List<int> encrypt(String msg) {
  var bytes = new List<int>.from(msg.codeUnits);
  return encryptBytes(bytes);
}

List<int> encryptBytes(List<int> data, {int firstKey = 0xab}) {
  var key = firstKey;
  var bytes = new List<int>.from(data);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] ^= key;
    key = bytes[i];
  }
  return bytes;
}

String decrypt(List<int> data) {
  return new String.fromCharCodes(decryptBytes(data));
}

List<int> decryptBytes(List<int> data, {int firstKey = 0xab}) {
  var key = firstKey;
  var bytes = new List<int>.from(data);
  for (var i = 0; i < bytes.length; i++) {
    var nextKey = bytes[i];
    bytes[i] ^= key;
    key = nextKey;
  }
  return bytes;
}

void findDevices() {
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 63585).then((RawDatagramSocket udpSocket) {
    udpSocket.broadcastEnabled = true;
    udpSocket.listen((e) {
      Datagram dg = udpSocket.receive();
      if (dg != null) {
        print("received ${dg.data}");
        print("received ${decrypt(dg.data)}");
      }
    });

    udpSocket.send(discoveryMsgBuf, broadcastAddr, 9999);
  });

}
