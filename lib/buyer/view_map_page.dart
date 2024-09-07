// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors, prefer_interpolation_to_compose_strings, sized_box_for_whitespace, sort_child_properties_last, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class ViewMapPage extends StatefulWidget {
  final double? centerLatitude;
  final double? centerLongitude;

  const ViewMapPage({this.centerLatitude, this.centerLongitude});

  @override
  _ViewMapPageState createState() => _ViewMapPageState();
}

class _ViewMapPageState extends State<ViewMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _locationController = TextEditingController();
  LatLng? _inputLocation;
  String? _distanceAndTimeEstimate;
  List<Marker> _markers = [];
  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
  }

  Future<void> _fetchMarkers() async {
    List<Marker> markers = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('addresses').get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double latitude = data['latitude'];
      double longitude = data['longitude'];
      String address = data['address'];

      markers.add(
        Marker(
          point: LatLng(latitude, longitude),
          width: 80.0,
          height: 80.0,
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40.0,
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    address,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _calculateDistanceAndTime(String location) async {
    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        _inputLocation = LatLng(locations[0].latitude, locations[0].longitude);

        // Find the closest marker to the searched location
        Marker? closestMarker;
        double closestDistance = double.infinity;
        final distanceCalculator = Distance();

        for (var marker in _markers) {
          final distance = distanceCalculator.as(
            LengthUnit.Kilometer,
            _inputLocation!,
            marker.point,
          );
          if (distance < closestDistance) {
            closestDistance = distance;
            closestMarker = marker;
          }
        }

        if (closestMarker != null) {
          _selectedMarker = closestMarker;

          // Update the time calculation to assume 60 km/h speed
          final timeInHours = closestDistance / 60; // 60 km/h speed
          int hours = timeInHours.floor();
          int minutes = ((timeInHours - hours) * 60).round();

          String timeEstimate = '';
          if (hours > 0) {
            timeEstimate += '${hours}hr ';
          }
          timeEstimate += '${minutes}min';

          _distanceAndTimeEstimate =
              'Distance: ${closestDistance.toStringAsFixed(2)} km, Estimated Time: $timeEstimate';

          setState(() {});
        }
      }
    } catch (e) {
      print('Error fetching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to find location: $location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter your location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _calculateDistanceAndTime(_locationController.text);
                  },
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Border color black
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Enabled border color black
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border color black with width
                ),
              ),
            ),
          ),
          if (_distanceAndTimeEstimate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _distanceAndTimeEstimate!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: widget.centerLatitude != null && widget.centerLongitude != null
                    ? LatLng(widget.centerLatitude!, widget.centerLongitude!)
                    : LatLng(13.0827, 80.2707),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_markers.isNotEmpty) MarkerLayer(markers: _markers),
                if (_inputLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _inputLocation!,
                        width: 80.0,
                        height: 80.0,
                        builder: (ctx) => Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                    ],
                  ),
                if (_selectedMarker != null)
                  MarkerLayer(
                    markers: [
                      _selectedMarker!,
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
