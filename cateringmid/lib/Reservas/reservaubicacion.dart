import 'package:cateringmid/Reservas/confirmacion.dart';
import 'package:cateringmid/Reservas/reservacliente.dart';
import 'package:cateringmid/Reservas/reservamap.dart';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CateringMID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: Reservaubicacion(
        id_empresa: '',
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', ''),
    );
  }
}

class Reservaubicacion extends StatefulWidget {
  const Reservaubicacion({super.key, required this.id_empresa});
  final String id_empresa;
  @override
  _ReservaubicacionState createState() => _ReservaubicacionState();
}

class _ReservaubicacionState extends State<Reservaubicacion> {
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _usercalleController = TextEditingController();
  final _usernamelocalController = TextEditingController();
  final _usernumberController = TextEditingController();
  final _userreferensController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isLoading = false;
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  Position? userLocation;

 /* void _onMarkerTapped() {
    if (_formKey.currentState?.validate() ?? false) {
      Provider.of<ReservasProvider>(context, listen: false).actualizarDireccion(
          _usernamelocalController.text,
          _usernumberController.text,
          _userreferensController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationPickerScreen()), 
      );
    }
  } */

 // chupala geovani
 // succionala 
 // chupala owsd

  Future<void> _getUserLocation() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      setState(() {
        userLocation = position;
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
    }
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      Provider.of<ReservasProvider>(context, listen: false).actualizarDireccion(
          _usernamelocalController.text,
          _usernumberController.text,
          _userreferensController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationPickerScreen(id_empresa: widget.id_empresa,)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    final reservasProvider =
        Provider.of<ReservasProvider>(context, listen: false);
    if (reservasProvider.direccion != null && reservasProvider.direccion!.isNotEmpty) {
      _usercalleController.text = reservasProvider.direccion!;
    }

    if (reservasProvider.nombreLugar != null &&
        reservasProvider.nombreLugar!.isNotEmpty) {
      _usernamelocalController.text = reservasProvider.nombreLugar!;
    }

    if (reservasProvider.numCasa != null &&
        reservasProvider.numCasa!.isNotEmpty) {
      _usernumberController.text = reservasProvider.numCasa!;
    }

    if (reservasProvider.referencias != null &&
        reservasProvider.referencias!.isNotEmpty) {
      _userreferensController.text = reservasProvider.referencias!;
    }
  }

  void fetchMoreData() async {
    if (isLoading) return; // Si ya estamos cargando, no hacer nada más

    setState(() {
      isLoading = true;
    });

    try {} catch (e) {

    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservasProvider =
        Provider.of<ReservasProvider>(context, listen: false);

    if (reservasProvider.latitud != null && reservasProvider.longitud != null) {
      // Convierte latitud y longitud a LatLng
      selectedLocation =
          LatLng(reservasProvider.latitud!, reservasProvider.longitud!);
    }

    return KeyboardDismisser(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Reservacion'),
              backgroundColor: const Color(0xFF670A0A),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              toolbarHeight: 90,
            ),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _bar(),
                      const SizedBox(height: 20),
                      _paso(),
                      const SizedBox(height: 20),
                      _datosentrega(),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(
                              300, 50), // Ancho fijo de 250 y alto de 50
                          backgroundColor: const Color(0xFF670A0A),
                          foregroundColor:
                              const Color.fromARGB(255, 240, 239, 239),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Siguiente'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget _bar() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        child: Row(children: [
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF670A0A), // Estado actual
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 2,
                    color: Color(0xFF670A0A), // Estado actual
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF670A0A), // Estado actual
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 2,
                    color: Color(0xFF670A0A), // Estado actual
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF670A0A), // Estado actual
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 2,
                    color: Colors.grey, // Estado actual
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey, // Estado actual
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]));
  }

  Widget _datosentrega() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        alignment: Alignment.topLeft,
        child: Column(children: [
          Text(
            'Datos de entrega', // Usamos la variable que corresponde a la empresa
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF670A0A),
                ),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _usernamelocalController,
        decoration: const InputDecoration(
          labelText: 'Nombre del lugar ',
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .grey), // Cambia el color de la línea inferior al enfocar
          ),
          suffixIcon: Icon(
            Icons.home,
            color: Color.fromARGB(
                255, 112, 110, 110), // Cambia el color si está enfocado
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese un nombre';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _usernumberController,
        decoration: const InputDecoration(
          labelText: 'No. Casa',
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .grey), // Cambia el color de la línea inferior al enfocar
          ),
          suffixIcon: Icon(
            Icons.home,
            color: Color.fromARGB(
                255, 112, 110, 110), // Cambia el color si está enfocado
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese un telefono';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _userreferensController,
        decoration: const InputDecoration(
          labelText: 'Referencias',
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .grey), // Cambia el color de la línea inferior al enfocar
          ),
          suffixIcon: Icon(
            Icons.home,
            color: Color.fromARGB(
                255, 112, 110, 110), // Cambia el color si está enfocado
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese una referencia';
          }
          return null;
        },
      )
    ]);
  }

 /*  Widget _datosubicacion() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        alignment: Alignment.topLeft,
        child: Column(children: [
          SizedBox(height: 30),
          Row(children: [
            Icon(
              Icons.location_on,
              size: 20,
              color: const Color(0xFF670A0A), // Color del ícono
            ),
            Text(
              'Ubicacion',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF670A0A),
                  ),
            ),
          ]),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width * 0.9,
                child: selectedLocation == null
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: (controller) {
                          setState(() {
                            mapController = controller;
                          });
                        },
                        initialCameraPosition: CameraPosition(
                          target: selectedLocation!,
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId("seleccionado"),
                            position: selectedLocation!,
                            onTap: _onMarkerTapped,
                          ),
                        },
                      ),
              ),
            ),
          ),
        ]),
      ),
    ]);
  } */

  Widget _paso() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(children: [
              Text(
                'Paso 3 de 4', // Usamos la variable que corresponde a la empresa
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF670A0A),
                    ),
              ),
              const SizedBox(width: 10),
            ]),
          ),
        ],
      ),
    );
  }
}
