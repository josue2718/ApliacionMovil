import 'package:cateringmid/Reservas/confirmacion.dart';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:cateringmid/Reservas/reservaubicacion.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class LocationMap extends StatefulWidget {
const LocationMap({super.key});
  @override
  _LocationMap createState() => _LocationMap();
}

class _LocationMap extends State<LocationMap> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  Position? userLocation;



  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _guardar() async {
 
      
}


  Future<void> _getUserLocation() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      setState(() {
        userLocation = position;
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error obteniendo la ubicación: $e");
    }
  }

  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      selectedLocation = tappedPoint;
    });
  }

  @override
  Widget build(BuildContext context) {
         final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);
         
  
         
    return Scaffold(
      appBar: AppBar(
            title: const Text('Empresas'),
            backgroundColor: const Color(0xFF670A0A),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 90,
            
          ),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: selectedLocation!,
                zoom: 15,
              ),
             markers: selectedLocation != null
  ? {
      Marker(
        markerId: MarkerId("seleccionado"),
        position: selectedLocation!,
      ),
    }
  : <Marker>{},  // Aquí se especifica que es un Set<Marker>

              onTap: _onMapTap,
            ),

      
    );
  }

}
class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Servicio de ubicación desactivado.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error("Permisos de ubicación denegados permanentemente.");
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}