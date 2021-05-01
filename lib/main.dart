import 'package:flutter/material.dart';
import 'tplink/api.dart';
import 'tplink/model.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlugSelector(),
    );
  }
}

class PlugSelector extends StatefulWidget {

  @override
  _PlugSelectorState createState() => _PlugSelectorState();
}

class _PlugSelectorState extends State<PlugSelector> {
  List<Device> _devices = [];
  Device _selectedDevice;

  @override
  initState() {
    super.initState();
    _updateDevices();
  }

  void _updateDevices() async {
    var devices = await findDevices(new Duration(seconds:2));
    print("found ${devices.length} devices");
    var stream = getUsageRealtime(devices[0]);
    print("subscribing...");
    var result = await stream.first;
    print("got result ${result}");
    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Choose a plug to monitor'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${_devices[index].name}'),
            subtitle: Text('${_devices[index].address}'),
            trailing: _selectedDevice == _devices[index] ? Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              setState(() {
                if (_selectedDevice != _devices[index])
                  _selectedDevice = _devices[index];
                else
                  _selectedDevice = null;
              });
            }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateDevices,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
