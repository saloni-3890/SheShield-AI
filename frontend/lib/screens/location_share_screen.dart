import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class LocationShareScreen extends StatefulWidget {
  const LocationShareScreen({super.key});

  @override
  State<LocationShareScreen> createState() => _LocationShareScreenState();
}

class _LocationShareScreenState extends State<LocationShareScreen> {
  bool isLoading = false;
  Position? position;

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please enable location services.');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. '
          'Enable it from app settings.',
        );
      }

      final currentPosition =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        position = currentPosition;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> shareLocation() async {
    if (position == null) {
      await getLocation();
    }

    if (position == null) return;

    final lat = position!.latitude;
    final lng = position!.longitude;

    final mapsLink =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    final message = '''
📍 My Current Location

I am sharing my current location with you.

Location:
$mapsLink

Latitude: $lat
Longitude: $lng
''';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Share Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
              ),
              child: Icon(
                Icons.location_on,
                size: 90,
                color: Colors.blue.shade700,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Your Current Location',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              position == null
                  ? 'Get your current GPS location and share it with someone you trust.'
                  : 'Location successfully detected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            if (position != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade100,
                ),
                child: Column(
                  children: [
                    Text(
                      'Latitude: ${position!.latitude.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Longitude: ${position!.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : getLocation,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  isLoading
                      ? 'GETTING LOCATION...'
                      : 'GET MY LOCATION',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed:
                    position == null ? null : shareLocation,
                icon: const Icon(Icons.share),
                label: const Text('SHARE LOCATION'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}