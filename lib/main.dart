import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_radar/flutter_radar.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Bluetooth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Radar Bluetooth'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key); // Added ? to key and required to title

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BluetoothDevice> devices = [];
  Timer? timer; // Added ? to timer

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getDevices();
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Use ?. to check for null before calling cancel
    super.dispose();
  }

  void _getDevices() async {
    var uri = Uri.parse('http://trackerblue.local/events');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<BluetoothDevice> devices = [];
      for (var device in data) {
        devices.add(BluetoothDevice(
          id: device['id'] as int, // Cast to int to avoid potential null errors
          address: device['address'] as String, // Cast to String
          rssi: device['rssi'] as int, // Cast to int
          name: device['name'] as String, // Cast to String
        ));
      }
      setState(() {
        this.devices = devices;
      });
    } else {
      print('Errore durante il recupero dei dispositivi Bluetooth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RadarChart(
              data: _getRadarData(devices),
              backgroundColor: Colors.blueGrey,
              fillColor: Colors.blue,
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devices[index].name),
                    subtitle: Text('${devices[index].rssi} dBm'),
                    trailing: Text('${devices[index].distance} m'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  List<RadarData> _getRadarData(List<BluetoothDevice> devices) {
    List<RadarData> data = [];
    for (var device in devices) {
      data.add(RadarData(
        value: device.rssi.toDouble(),
        label: device.name,
      ));
    }
    return data;
  }
}

  class RadarChart extends StatefulWidget {
  final List<RadarData> data;
  final Color backgroundColor;
  final Color fillColor;

  const RadarChart({
  Key? key,
  required this.data,
  required this.backgroundColor,
  required this.fillColor,
  }) : super(key: key);

  @override
  State<RadarChart> createState() => _RadarChartState();
  }

  class _RadarChartState extends State<RadarChart> {
  @override
  Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;

  // Calculate dimensions based on size
  final radius = size.width / 2;
  final center = Offset(size.width / 2, size.height / 2);

  return CustomPaint(
  size: Size.square(size.width),
  painter: RadarChartPainter(
  data: widget.data,
  backgroundColor: widget.backgroundColor,
  fillColor: widget.fillColor,
  radius: radius,
  center: center,
  ),
  );
  }
  }

  class RadarChartPainter extends CustomPainter {
  final List<RadarData> data;
  final Color backgroundColor;
  final Color fillColor;
  final double radius;
  final Offset center;

  const RadarChartPainter({
  required this.data,
  required this.backgroundColor,
  required this.fillColor,
  required this.radius,
  required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
  // Draw background grid
  drawBackgroundGrid(canvas, radius, center);

  // Draw data points and connect them
  drawDataPoints(canvas, radius, center);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  // Implementation details for drawing the grid and data points
  void drawBackgroundGrid(Canvas canvas, double radius, Offset center) {
  // ... your implementation ...
  }

  void drawDataPoints(Canvas canvas, double radius, Offset center) {
  // ... your implementation ...
  }
  }


class RadarData {

  final double value;
  final String label;

  RadarData({
  required this.value,
  required this.label,
  });
  }


class BluetoothDevice {
  final int id;
  final String address;
  final int rssi;
  final String name;
  double distance = 0.0; // Initialize distance to 0.0

  BluetoothDevice({
    required this.id,
    required this.address,
    required this.rssi,
    required this.name,
  });

  @override
  String toString() {
    return 'BluetoothDevice{id: $id, address: $address, rssi: $rssi, name: $name}';
  }
}
