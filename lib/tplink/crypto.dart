List<int> encrypt(String msg) {
  var bytes = new List<int>.from(msg.codeUnits);
  return _encryptBytes(bytes);
}

List<int> _encryptBytes(List<int> data, {int firstKey = 0xab}) {
  var key = firstKey;
  var bytes = new List<int>.from(data);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] ^= key;
    key = bytes[i];
  }
  return bytes;
}

String decrypt(List<int> data) {
  return new String.fromCharCodes(_decryptBytes(data));
}

List<int> _decryptBytes(List<int> data, {int firstKey = 0xab}) {
  var key = firstKey;
  var bytes = new List<int>.from(data);
  for (var i = 0; i < bytes.length; i++) {
    var nextKey = bytes[i];
    bytes[i] ^= key;
    key = nextKey;
  }
  return bytes;
}
