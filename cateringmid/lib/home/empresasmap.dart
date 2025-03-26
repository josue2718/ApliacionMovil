import 'dart:convert';
import 'package:cateringmid/Empresa/empresa.dart';
import 'package:cateringmid/home/api_mapemp.dart';
import 'package:cateringmid/menu%20despegable/CustomDrawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({super.key});

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  Position? userLocation;
  final ApiclassMapa mapa = ApiclassMapa();
   final ValueNotifier<bool> _hasNotification = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    mapa.fetchEmpresaData();
     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _hasNotification.value = true; // Marcar que hay una nueva notificación
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Empresas'),
        backgroundColor: const Color(0xFF670A0A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 90,
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: _hasNotification,
              builder: (context, hasNotification, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificaciones')),
                        );
                        _hasNotification.value = false; // Marcar como leído
                      },
                    ),
                    if (hasNotification) // Si hay notificación, mostrar punto rojo
                      Positioned(
                        right: 8,
                        top: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
                  ],
      ),
      body: userLocation == null
          ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF670A0A),
                  ),
                )
          : GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: selectedLocation!,
                zoom: 13,
              ),
              markers: _crearMarcadores(),
            ),
    );
  }

  // Función para generar los marcadores de las empresas
  Set<Marker> _crearMarcadores() {
    return mapa.empresasmapa.map((empresa) {
      print("Empresas en el mapa: ${mapa.empresasmapa}");

      return Marker(
        markerId: MarkerId(empresa.nombre),
        position: LatLng(empresa.latitud, empresa.longitud),
        infoWindow: InfoWindow(
          title: empresa.nombre,
          snippet: "Toque para ver más",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyPage(id_empresa: empresa.id_empresa,)),
              );
          },
        ),
      );
    }).toSet();
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
