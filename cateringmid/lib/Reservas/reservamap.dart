import 'package:cateringmid/Reservas/confirmacion.dart';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:cateringmid/Reservas/reservaubicacion.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class LocationPickerScreen extends StatefulWidget {
const LocationPickerScreen({super.key, required this.id_empresa});
final String id_empresa;
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  Position? userLocation;



  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _guardar() async {
  if (selectedLocation != null) {
    final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);

    // Obtener la dirección de la API de Google Maps
    String direccion = await Locationdireccion.getAddressFromCoordinates(
        selectedLocation!.latitude, selectedLocation!.longitude);

    // Actualizar la dirección en el proveedor
    reservasProvider.actualizarDireccionmap(
      direccion, 
      selectedLocation!.latitude,
      selectedLocation!.longitude,
 
    );

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Ubicación seleccionada: $direccion"),
            backgroundColor: Color(0xFF670A0A)),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => confrimacionreserva(
                  id_empresa: widget
                      .id_empresa))); // Reemplaza `YourPage` con la página actual
    }
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
            title: const Text('Mi ubicacion'),
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
      floatingActionButton: _button()
      
    );
  }

  Widget _button()
  {
return FloatingActionButton(
  backgroundColor:Color(0xFF670A0A) ,
        child: Icon(Icons.check, color: Color.fromARGB(255, 255, 255, 255),),
        onPressed: () {
          _guardar();
        }
        );
  }
}

class Locationdireccion {
  static const String googleMapsApiKey = 'AIzaSyCxGkc4ll6wpkhgC2WtCG8EG2q0lCFAskY'; // Asegúrate de agregar tu clave aquí

  // Función para obtener la dirección a partir de las coordenadas
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapsApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, extraemos la dirección
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address']; // La dirección formateada
      } else {
        return 'Dirección no encontrada';
      }
    } else {
      throw Exception('Error al obtener la dirección: ${response.statusCode}');
    }
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