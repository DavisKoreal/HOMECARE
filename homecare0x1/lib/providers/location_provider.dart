// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:homecare0x1/models/location.dart';


// class LocationProvider with ChangeNotifier {
//   final List<Location> _locations = [
//     Location(latitude: 37.7749, longitude: -122.4194),
//     Location(latitude: 37.7849, longitude: -122.4094),
//     Location(latitude: 37.7949, longitude: -122.4294),
//     Location(latitude: 37.7649, longitude: -122.3994),
//     Location(latitude: 37.7549, longitude: -122.4394),
//   ];

//   Location getRandomLocation() {
//     final random = Random();
//     return _locations[random.nextInt(_locations.length)];
//   }

//   Location getProductionLocation() {
//     return Location(latitude: 37.7749, longitude: -122.4194);
//   }
// }


import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homecare0x1/models/location.dart';

class LocationProvider with ChangeNotifier {
  final List<Location> _locations = [
    Location(latitude: 37.7749, longitude: -122.4194),
    Location(latitude: 37.7849, longitude: -122.4094),
    Location(latitude: 37.7949, longitude: -122.4294),
    Location(latitude: 37.7649, longitude: -122.3994),
    Location(latitude: 37.7549, longitude: -122.4394),
  ];

  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get random location from predefined list
  Location getRandomLocation() {
    final random = Random();
    return _locations[random.nextInt(_locations.length)];
  }

  // Main function that returns {TimeStamp, Location(Latitude, Longitude)}
  Future<Map<String, dynamic>> getLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 15),
      );

      _isLoading = false;
      notifyListeners();

      // Return the exact object structure you requested
      return {
        'TimeStamp': DateTime.now(),
        'Location': {
          'Latitude': _currentPosition!.latitude,
          'Longitude': _currentPosition!.longitude,
        }
      };

    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      
      // Fallback to random location with same structure
      return {
        'TimeStamp': DateTime.now(),
        'Location': {
          'Latitude': 0,
          'Longitude': 0,
        }
      };
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset location data
  void reset() {
    _currentPosition = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}