import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class BasicMapTest extends StatefulWidget {
  const BasicMapTest({super.key});

  @override
  State<BasicMapTest> createState() => _BasicMapTestState();
}

class _BasicMapTestState extends State<BasicMapTest> {
  bool _mapCreated = false;
  String _errorMessage = '';
  MapType _currentMapType = MapType.normal;
  
  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-6.2088, 106.8456), // Jakarta coordinates
    zoom: 12.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Map Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          PopupMenuButton<MapType>(
            onSelected: (MapType type) {
              setState(() {
                _currentMapType = type;
                print("Changed to map type: $type");
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MapType>>[
              const PopupMenuItem<MapType>(
                value: MapType.normal,
                child: Text('Normal'),
              ),
              const PopupMenuItem<MapType>(
                value: MapType.satellite,
                child: Text('Satellite'),
              ),
              const PopupMenuItem<MapType>(
                value: MapType.hybrid,
                child: Text('Hybrid'),
              ),
              const PopupMenuItem<MapType>(
                value: MapType.terrain,
                child: Text('Terrain'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialPosition,
              mapType: _currentMapType,
              onMapCreated: (controller) {
                print("Map created successfully!");
                setState(() {
                  _mapCreated = true;
                });
              },
              onCameraMove: (position) {
                print("Camera moved to: ${position.target}");
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('API Key: AIzaSyBAeKngtUoBtDDR6wSAV2SDn27YJIyeZ9o'),
                Text('Map Created: $_mapCreated'),
                Text('Platform: ${Platform.operatingSystem}'),
                if (_errorMessage.isNotEmpty)
                  Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    print("Checking map status");
                    setState(() {});
                  },
                  child: const Text('Check Map Status'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 