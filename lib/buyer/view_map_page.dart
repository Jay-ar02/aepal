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
  Marker? _selectedMarker;
  String? _address; // To store the fetched address

  @override
  void initState() {
    super.initState();
    _fetchAddress(); // Fetch the specific address from Firestore
  }

  // Function to fetch the address from Firestore based on latitude and longitude
  Future<void> _fetchAddress() async {
    try {
      // Query Firestore for the address using latitude and longitude
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('latitude', isEqualTo: widget.centerLatitude)
          .where('longitude', isEqualTo: widget.centerLongitude)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        _address = data['address']; // Store the address

        _showSelectedLocation(); // Display the marker once the address is fetched
      } else {
        print('Address not found for the given coordinates.');
      }
    } catch (e) {
      print('Error fetching address from Firestore: $e');
    }
  }

  // Function to set the marker for the selected location
  void _showSelectedLocation() {
    LatLng selectedLocation = LatLng(widget.centerLatitude!, widget.centerLongitude!);
    _selectedMarker = Marker(
      point: selectedLocation,
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
          if (_address != null)
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
                  _address!, // Use the fetched address
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
        ],
      ),
    );
    setState(() {}); // Update the UI
  }

  Future<void> _calculateDistanceAndTime(String location) async {
    // Optional if you want to keep the distance calculation logic
    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        _inputLocation = LatLng(locations[0].latitude, locations[0].longitude);

        // Calculate distance from the input location to the selected marker location
        final distanceCalculator = Distance();
        final distance = distanceCalculator.as(
          LengthUnit.Kilometer,
          _inputLocation!,
          LatLng(widget.centerLatitude!, widget.centerLongitude!),
        );

        final timeInHours = distance / 60; 
        int hours = timeInHours.floor();
        int minutes = ((timeInHours - hours) * 60).round();

        String timeEstimate = '';
        if (hours > 0) {
          timeEstimate += '${hours}hr ';
        }
        timeEstimate += '${minutes}min';

        _distanceAndTimeEstimate =
            'Distance: ${distance.toStringAsFixed(2)} km, Estimated Time: $timeEstimate';

        setState(() {});
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
    LatLng centerPoint = widget.centerLatitude != null && widget.centerLongitude != null
        ? LatLng(widget.centerLatitude!, widget.centerLongitude!)
        : LatLng(13.0827, 80.2707); // Default to Chennai if no center provided

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
                center: centerPoint,
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                // Show the marker for the selected location
                if (_selectedMarker != null)
                  MarkerLayer(
                    markers: [
                      _selectedMarker!,
                    ],
                  ),
                // Optionally, display the searched location as a blue marker
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
