import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  // Nullable controller to prevent initialization errors
  GoogleMapController? _mapController;

  // Default location with explicit type
  final LatLng _defaultLocation = const LatLng(6.9271, 79.8612); // Colombo

  // State variables
  bool _isLoading = true;
  String _errorMessage = '';
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Explicitly check location permissions
      LocationPermission permission = await _checkLocationPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _handleError('Location permissions are required');
        return;
      }

      // Try to get current position
      Position? position = await _getCurrentLocation();

      setState(() {
        // Use current location or fallback to default
        _currentLocation =
            position != null
                ? LatLng(position.latitude, position.longitude)
                : _defaultLocation;
        _isLoading = false;
      });
    } catch (e) {
      _handleError('Map initialization failed: ${e.toString()}');
    }
  }

  Future<LocationPermission> _checkLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _handleError('Location services are disabled');
      return LocationPermission.denied;
    }

    // Request permission
    return await Geolocator.requestPermission();
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      _handleError('Could not retrieve location: ${e.toString()}');
      return null;
    }
  }

  void _handleError(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
      _currentLocation = _defaultLocation;
    });

    // Optional: Show error in a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Waste Bins Map')),
      body: _buildMapView(),
    );
  }

  Widget _buildMapView() {
    // Loading state
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state with retry option
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _initializeMap();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Ensure _currentLocation is not null
    final displayLocation = _currentLocation ?? _defaultLocation;

    // Map view
    return GoogleMap(
      // Null-safe initialization
      initialCameraPosition: CameraPosition(target: displayLocation, zoom: 15),
      // Null-safe map type
      mapType: MapType.normal,

      // Enable location features
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,

      // Null-safe map creation
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }
}
