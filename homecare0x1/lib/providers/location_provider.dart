import 'dart:math';
import 'package:flutter/material.dart';

class Location {
  double latitude;
  double longitude;

  Location({required this.latitude, required this.longitude});
}

class LocationProvider with ChangeNotifier {
  final List<Location> _locations = [
    Location(latitude: 37.7749, longitude: -122.4194),
    Location(latitude: 37.7849, longitude: -122.4094),
    Location(latitude: 37.7949, longitude: -122.4294),
    Location(latitude: 37.7649, longitude: -122.3994),
    Location(latitude: 37.7549, longitude: -122.4394),
  ];

  Location getRandomLocation() {
    final random = Random();
    return _locations[random.nextInt(_locations.length)];
  }
}
