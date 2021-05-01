import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'tplink/api.dart';
import 'tplink/model.dart';

const double MAX_POWER_WATTS = 2400; // 240V x 10A
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
  List<EnergyUsage> _usage = [];

  @override
  initState() {
    super.initState();
    _updateDevices();
  }

  void _updateDevices() async {
    var devices = await findDevices(new Duration(seconds:2));
    List<EnergyUsage> usage = [];
    for (var d in devices) {
      var subscribed = getUsageRealtime(devices[0]);
      usage.add(await subscribed.first);
      // todo subscribe for power changes and close view when we don't need it
      // subscribed.
    }

    setState(() {
      _devices = devices;
      _usage = usage;
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
            leading: CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 5.0,
              percent: _usage[index].powerW/MAX_POWER_WATTS,
              center: Text('${(_usage[index].powerW/1000).round()}%'),
              progressColor: Colors.blue,
            ),
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
