import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'tplink/api.dart';
import 'tplink/model.dart';
import 'notify.dart';

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
  StreamSubscription _subscription;

  @override
  initState() {
    super.initState();
    _updateDevices();
  }

  void _updateDevices() async {
    if (_subscription != null) {
      _subscription.cancel();
    }

    var devices = await findDevices(new Duration(seconds:2));
    var usage_updates =_createUsageSubscription();
    var sub = usage_updates.listen((usage) {
      print('updating...');
      setState(() {
        _usage = usage;
      });
    });

    setState(() {
      _devices = devices;
      _subscription = sub;
    });

    var notify = new Notify();
    await notify.setup();
    await notify.show();
  }

  Stream<List<EnergyUsage>> _createUsageSubscription() async* {
    while(true) {
      List<EnergyUsage> usage = [];
      for (var d in _devices) {
        usage.add(await readEnergyUsage(d));
      }
      yield usage;
      await Future.delayed(Duration(seconds:10));
    }
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
            leading: index < _usage.length ? CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 5.0,
              percent: _usage[index].powerW/MAX_POWER_WATTS,
              center: Text('${(_usage[index].powerW/1000).round()}%'),
              progressColor: Colors.blue,
            ) : null,
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
