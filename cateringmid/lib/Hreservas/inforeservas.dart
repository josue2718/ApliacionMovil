import 'dart:async';

import 'package:cateringmid/Hreservas/apimireserva.dart';
import 'package:cateringmid/Hreservas/pagoreserva.dart';

import 'package:cateringmid/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data with Infinite Scroll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
      ),
      home: infohreserva(
        id_reserva: '1',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class infohreserva extends StatefulWidget {
  final String id_reserva;
  // Constructor con ambos parámetros
  const infohreserva({
    Key? key,
    required this.id_reserva,
  }) : super(key: key);

  @override
  _infohreserva createState() => _infohreserva();
}

class _infohreserva extends State<infohreserva> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final Apimireserva apimireserva = Apimireserva();
  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;

  bool personalizar = false;

  @override
  void initState() {
    super.initState();
    apimireserva.fetchMenuinfoData(widget.id_reserva);
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose(); // Libera el recurso
    _scrollController.dispose(); // Libera el controlador de scroll
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: FutureBuilder(
          future:
              Future.wait([apimireserva.fetchMenuinfoData(widget.id_reserva)]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF670A0A),
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Reservacion'),
                backgroundColor: const Color(0xFF670A0A),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                toolbarHeight: 90,
              ),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              body: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _info(),
                      const SizedBox(height: 10),
                      _title2(),
                      const SizedBox(height: 10),
                      _menus(),
                      const SizedBox(height: 20),
                      _title3(),
                      const SizedBox(height: 10),
                      _bar(),
                      const SizedBox(height: 30),
                      _button(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bar() {
    return ListView.builder(
      itemCount: apimireserva.inforeserva.length + (isLoading ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimireserva.inforeserva.length) {
          final estatus = apimireserva.infoestatus[index];
          return Column(
            children: [
              Estatus(
                  enviado: estatus.enviado,
                  aceptado: estatus.aceptado,
                  pago: estatus.pago,
                  preparando: estatus.preparando,
                  enviando: estatus.enviando,
                  completado: estatus.completado,
                  cancelado: estatus.cancelado)
            ],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _menus() {
    return ListView.builder(
      itemCount: apimireserva.infomenu.length + (isLoading ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimireserva.infomenu.length) {
          final menu = apimireserva.infomenu[index];
          return CustomerCart(
            cantidad: menu.menuCantidad,
            nombre: menu.menuNombre,
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _info() {
    return ListView.builder(
      itemCount: apimireserva.inforeserva.length + (isLoading ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimireserva.inforeserva.length) {
          final info = apimireserva.inforeserva[index];
          final direccion = apimireserva.infodireccion[index];
          final cliente = apimireserva.infocliente[index];
          final estatus = apimireserva.infoestatus[index];
          return Column(
            children: [
              nombreempresa(nombre: info.empresaNombre),
              infopago(costo: info.costo, anticipo: info.anticipo),
              infoentrega(
                direccion: direccion.direccion,
                lugar: direccion.nombreLugar,
                hora: info.hora,
                fecha: info.fecha,
              ),
              infocliente(
                primerNombre: cliente.primerNombre,
                segundoNombre: cliente.segundoNombre,
                primerTelefono: cliente.primerTelefono,
                segundoTelefono: cliente.segundoTelefono,
              ),
              informacionespecialidades(
                  mobiliario: info.mobiliario,
                  blancos: info.blancos,
                  personal: info.personal,
                  cristaleria: info.cristaleria,
                  meseros: info.meseros,
                  cantidadMeseros: info.cantidadmeseros,
                  chef: info.chef),
              infoubicacion(
                latitud: direccion.latitud,
                longitud: direccion.longitud,
              ),
            ],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _button() {
    return ListView.builder(
      itemCount: apimireserva.inforeserva.length + (isLoading ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimireserva.inforeserva.length) {
          final estatus = apimireserva.infoestatus[index];
          return Column(
            children: [
              Buttonclass(
                  enviado: estatus.enviado,
                  aceptado: estatus.aceptado,
                  pago: estatus.pago,
                  preparando: estatus.preparando,
                  enviando: estatus.enviando,
                  completado: estatus.completado,
                  cancelado: estatus.cancelado)
            ],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _title() {
    return Text(
      'Mi Reserva', // Usamos la variable que corresponde a la empresa
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF670A0A),
          ),
    );
  }

  Widget _title2() {
    return Container(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Text(
              'Menus seleccionados', // Usamos la variable que corresponde a la empresa
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF670A0A),
                  ),
            )));
  }

  Widget _title3() {
    return Container(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Text(
              'Estatus', // Usamos la variable que corresponde a la empresa
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF670A0A),
                  ),
            )));
  }
}

class infoentrega extends StatelessWidget {
  String fecha;
  String hora;
  String direccion;
  String lugar;

  infoentrega({
    required this.direccion,
    required this.lugar,
    required this.fecha,
    required this.hora,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos de entrega', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF670A0A),
                      ),
                ),
                const SizedBox(height: 15),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hora del evento: $hora',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Fecha del evento: $fecha',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Direccion: $direccion',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.home,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nombre del lugar: $lugar',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 5)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Estatus extends StatelessWidget {
  final bool enviado;
  final bool aceptado;
  final bool pago;
  final bool preparando;
  final bool enviando;
  final bool completado;
  final bool cancelado;

  const Estatus({
    required this.enviado,
    required this.aceptado,
    required this.pago,
    required this.preparando,
    required this.enviando,
    required this.completado,
    required this.cancelado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      child: Column(
        children: [
          if (!cancelado && (enviado || completado))
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF670A0A), // Estado actual
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: const Color(0xFF670A0A), // Estado actual
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tu reserva ha sido enviada',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF670A0A), // Estado actual
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (!cancelado && (aceptado || completado))
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF670A0A), // Estado actual
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: const Color(0xFF670A0A), // Estado actual
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tu reserva ha sido aceptada',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF670A0A), // Estado actual
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (!cancelado && (pago || completado))
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF670A0A), // Estado actual
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: const Color(0xFF670A0A), // Estado actual
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  'El pago ha sido confirmado',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF670A0A), // Estado actual
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (!cancelado && (preparando || completado))
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF670A0A), // Estado actual
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: const Color(0xFF670A0A), // Estado actual
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  'Estamos preparando tu servicio',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF670A0A), // Estado actual
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (!cancelado && (enviando || completado))
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF670A0A), // Estado actual
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: const Color(0xFF670A0A), // Estado actual
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tu servicio está en camino',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF670A0A), // Estado actual
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (cancelado)
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey, // Estado actual
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tu reserva ha sido cancelada',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey, // Estado actual
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          // Estado "Completado"
          if (!cancelado)
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            completado ? const Color(0xFF670A0A) : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (!cancelado && (completado == true)) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'Reserva Completada',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF670A0A), // Estado actual
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ],
            ),
        ],
      ),
    );
  }
}

class infoubicacion extends StatelessWidget {
  double latitud;
  double longitud;

  infoubicacion({required this.latitud, required this.longitud});

  @override
  Widget build(BuildContext context) {
    late GoogleMapController mapController;
    LatLng? selectedLocation;
    selectedLocation = LatLng(latitud, longitud!);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            alignment: Alignment.topLeft,
            child: Column(children: [
              Row(children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: const Color(0xFF670A0A), // Color del ícono
                ),
                Text(
                  'Ubicacion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
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
                            onMapCreated: (controller) {},
                            initialCameraPosition: CameraPosition(
                              target: selectedLocation!,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId("seleccionado"),
                                position: selectedLocation!,
                              ),
                            },
                          ),
                  ),
                ),
              ),
            ]),
          ),
        ]));
  }
}

class infopago extends StatelessWidget {
  double costo;
  double anticipo;

  infopago({
    required this.costo,
    required this.anticipo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos de Pago', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF670A0A),
                      ),
                ),
                const SizedBox(height: 15),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Costo total: \$${costo}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Anticipo a pagar: \$${anticipo}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class informacionespecialidades extends StatelessWidget {
  informacionespecialidades({
    required this.mobiliario,
    required this.blancos,
    required this.personal,
    required this.cristaleria,
    required this.meseros,
    required this.cantidadMeseros,
    required this.chef,
  });

  final int cantidadMeseros;
  final bool mobiliario;
  final bool blancos;
  final bool personal;
  final bool cristaleria;
  final bool meseros;
  final bool chef;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 0),
              Text(
                'Servicios Adicionales?', // Usamos la variable que corresponde a la empresa
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF670A0A),
                    ),
              ),
              const SizedBox(height: 5),
              if (mobiliario == true) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.table_bar,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mobiliario',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
              if (blancos == true) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.table_bar,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Blancos',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
              if (personal == true) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.person,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Personal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
              if (cristaleria == true) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.wine_bar,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Cristaleria',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
              if (meseros == true) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.person,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Meseros ${cantidadMeseros}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
              if (chef == true) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.person,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Chef',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 1),
            ]),
          ),
        ],
      ),
    );
  }
}

class infocliente extends StatelessWidget {
  String primerNombre;
  String segundoNombre;
  String primerTelefono;
  String segundoTelefono;

  infocliente({
    required this.primerNombre,
    required this.segundoNombre,
    required this.primerTelefono,
    required this.segundoTelefono,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos de cliente', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF670A0A),
                      ),
                ),
                const SizedBox(height: 15),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.person,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nombre del destinatario: $primerNombre ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.phone,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Teléfono del destinatario: $primerTelefono',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.person,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nombre del contacto adicional: $segundoNombre',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.phone,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Teléfono alternativo: $segundoTelefono',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 5)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerCart extends StatelessWidget {
  CustomerCart({
    required this.cantidad,
    required this.nombre,
  });

  final int cantidad;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
        ),
        color: const Color.fromARGB(255, 255, 255, 255),
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Container(
                      width: 200,
                      child: Expanded(
                        child: Text(
                          nombre,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines:
                              2, // Ajusta el número de líneas según sea necesario
                        ),
                      )),
                  Container(
                    width: 200,
                    child: Text(
                      'Cantidad: $cantidad',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 13,
                            color: Color.fromARGB(246, 134, 129, 120),
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines:
                          2, // Ajusta el número de líneas según sea necesario
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class nombreempresa extends StatelessWidget {
  nombreempresa({
    required this.nombre,
  });

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          alignment: Alignment.topLeft,
          child: Expanded(
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 30,
                color: Color(0xFF6A77E2E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class Buttonclass extends StatelessWidget {
  final bool enviado;
  final bool aceptado;
  final bool pago;
  final bool preparando;
  final bool enviando;
  final bool completado;
  final bool cancelado;

  const Buttonclass({
    required this.enviado,
    required this.aceptado,
    required this.pago,
    required this.preparando,
    required this.enviando,
    required this.completado,
    required this.cancelado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      child: Column(
        children: [
          if (!cancelado && !pago && !aceptado && !completado  && (enviado ))
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize:
                    const Size(200, 50), // Ancho fijo de 250 y alto de 50
                backgroundColor: const Color(0xFF670A0A),
                foregroundColor: const Color.fromARGB(255, 240, 239, 239),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Cancelar'),
                ],
              ),
            ),
          if (!cancelado && !pago && !completado  && aceptado )
            ElevatedButton(
              onPressed: () {
                  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(),
                ),
              );

              },
              style: ElevatedButton.styleFrom(
                fixedSize:
                    const Size(200, 50), // Ancho fijo de 250 y alto de 50
                backgroundColor: const Color(0xFF670A0A),
                foregroundColor: const Color.fromARGB(255, 240, 239, 239),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pagar'),
                ],
              ),
            ),
          if (pago &&  !completado  &&  !preparando &&!cancelado )
           ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 50), // Ancho fijo de 250 y alto de 50
        backgroundColor: const Color(0xFF670A0A),
        foregroundColor: const Color.fromARGB(255, 240, 239, 239),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Cancelar'),
        ],
      ),
    ),

           
    if (!cancelado && ( completado))
           ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 50), // Ancho fijo de 250 y alto de 50
        backgroundColor: const Color(0xFF670A0A),
        foregroundColor: const Color.fromARGB(255, 240, 239, 239),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Confirmar'),
        ],
      ),
    ),
          if (cancelado)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize:
                    const Size(200, 50), // Ancho fijo de 250 y alto de 50
                backgroundColor: const Color(0xFF670A0A),
                foregroundColor: const Color.fromARGB(255, 240, 239, 239),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Eliminar'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
