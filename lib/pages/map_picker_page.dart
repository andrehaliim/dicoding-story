import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story/helpers/location_helper.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late Future<LatLng> _centerFuture;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _centerFuture = _devicePosition();
  }

  Future<LatLng> _devicePosition() async {
    final position = await LocationHelper().determinePosition();
    return LatLng(position!.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
          ),
        ],
      ),
      body: FutureBuilder<LatLng>(
        future: _centerFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          } else if (asyncSnapshot.hasData) {
            final center = asyncSnapshot.data!;
            _selectedLocation ??= center;

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: 16,
                  ),

                  onCameraMove: (position) {
                    _selectedLocation = position.target;
                  },
                ),

                const Center(
                  child: Icon(Icons.location_pin, size: 50, color: Colors.red),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
