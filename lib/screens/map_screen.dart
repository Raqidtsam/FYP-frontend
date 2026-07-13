import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../models/district.dart';
import 'recommendation_screen.dart';

class MapScreen extends StatefulWidget {
  final double? targetLat;
  final double? targetLng;
  final String? targetName;
  final int? districtId;
  final String? districtName;

  const MapScreen({
    super.key,
    this.targetLat,
    this.targetLng,
    this.targetName,
    this.districtId,
    this.districtName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  List<District> _districts = [];
  bool _loading = true;

  static const double southLat = -6.5;
  static const double northLat = -4.8;
  static const double westLng = 39.1;
  static const double eastLng = 39.9;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final districts = await _apiService.getDistricts();
      setState(() {
        _districts = districts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = widget.targetLat ?? -6.15;
    final centerLng = widget.targetLng ?? 39.3;
    final zoom = widget.targetLat != null ? 13.0 : 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.targetName ?? 'Zanzibar Map'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (widget.districtId != null && widget.districtName != null)
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Area: ${widget.targetName}\nDistrict: ${widget.districtName}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecommendationScreen(
                            districtId: widget.districtId!,
                            districtName: widget.districtName!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                    ),
                    child: const Text(
                      'View Investments',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(centerLat, centerLng),
                      initialZoom: zoom,
                      minZoom: 9.0,
                      maxZoom: 16.0,
                      cameraConstraint: CameraConstraint.contain(
                        bounds: LatLngBounds(
                          const LatLng(southLat, westLng),
                          const LatLng(northLat, eastLng),
                        ),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.smart_geo_app',
                      ),
                      MarkerLayer(
                        markers: _districts.map((district) {
                          return Marker(
                            point:
                                LatLng(district.latitude, district.longitude),
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecommendationScreen(
                                      districtId: district.id,
                                      districtName: district.name,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.red, size: 40),
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      district.name,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}