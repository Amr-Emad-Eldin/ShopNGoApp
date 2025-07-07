import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/Tabs/Home/Home_Screen.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng _initialLatLng = LatLng(29.958491, 31.260597); // Cairo

  static const CameraPosition _initialPosition = CameraPosition(
    target: _initialLatLng,
    zoom: 14.0,
  );

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId("marker_1"),
      position: _initialLatLng,
      infoWindow: InfoWindow(title: "ShopNGo, Maadi"),
    ),
  };

  String _currentLocationText = "ShopNGo , Maadi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentLocationText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(Icons.search, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(

                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  HomeScreen()),
                        );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location confirmed!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:AppTheme.darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric( vertical: 16),
                    ),
                    child: const Text(
                      "Confirm Location",
                      style: TextStyle(fontSize:22 , color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
