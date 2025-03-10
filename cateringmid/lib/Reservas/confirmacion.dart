import 'dart:async';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'reservamenu.dart';

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
      home: confrimacionreserva(
        id_empresa: '1',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class confrimacionreserva extends StatefulWidget {
  final String id_empresa;
  // Constructor con ambos parámetros
  const confrimacionreserva({
    Key? key,
    required this.id_empresa,
  }) : super(key: key);

  @override
  _confrimacionreserva createState() => _confrimacionreserva();
}

class _confrimacionreserva extends State<confrimacionreserva> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final ReservaMenu reservamenu = ReservaMenu();
  final MenusR menusr = MenusR();

  ReservasProvider reserva = ReservasProvider();
  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;

  bool personalizar = false;

  @override
  void initState() {
    super.initState();
  }

  void _login() async {
    reserva.enviarReserva(empresa: widget.id_empresa, context: context);
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
          future: Future.wait([]),
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Column(
                    children: [
                      _bar(),
                      _paso(),
                      const SizedBox(height: 20),
                      _title(),
                      const SizedBox(height: 10),
                      infopago(),
                      infoentrega(),
                      infocliente(),
                      infoespecialidades(),
                      infoubicacion(),
                      _title2(),
                      const SizedBox(height: 10),
                      _menus(),
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

  Widget _paso() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(children: [
              Text(
                'Paso 4 de 4', // Usamos la variable que corresponde a la empresa
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

  Widget _bar() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
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
                ],
              ),
            ],
          ),
        ]));
  }

  Widget _menus() {
    return ListView.builder(
      itemCount: reservamenu.menu.length + (isLoading ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < reservamenu.menu.length & menusr.menureserva.length) {
          final menu = reservamenu.menu[index];
          final cantidadm = menusr.menureserva[index];
          return CustomerCart(
            link_imagen: menu.linkImagen,
            nombre: menu.nombre,
            cantidad: cantidadm.cantidadt,
          );
        } else {
          return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No se escogio algun menu',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(246, 134, 129, 120),
                  fontWeight: FontWeight.bold,
                ),
              ));
        }
      },
    );
  }

  Widget _button() {
    return ElevatedButton(
      onPressed: () {
        _login();
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(300, 50), // Ancho fijo de 250 y alto de 50
        backgroundColor: const Color(0xFF670A0A),
        foregroundColor: const Color.fromARGB(255, 240, 239, 239),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Reservar'),
        ],
      ),
    );
  }

  Widget _title() {
    return Text(
      'Confirmar datos', // Usamos la variable que corresponde a la empresa
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Color(0xFF670A0A),
          ),
    );
  }

  Widget _title2() {
    return Padding(
      padding: const EdgeInsets.all(10),
     child: Container(
      alignment: Alignment.topLeft,
      child:
      Text(
      'Menus seleccionados', // Usamos la variable que corresponde a la empresa
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF670A0A),
          ),
      )
              
    ));
  }
}

class infopago extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reservasProvider =
        Provider.of<ReservasProvider>(context, listen: false);
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
                      'Costo total: ${reservasProvider.costo!}',
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
                      'Anticipo a pagar: \$${reservasProvider.anticipo!}',
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


class infoentrega extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reservasProvider =
        Provider.of<ReservasProvider>(context, listen: false);
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
                      'Hora del evento: ${reservasProvider.hora!}',
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
                      'Fecha del evento: ${reservasProvider.fecha!}',
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
                        'Direccion: ${reservasProvider.direccion!}',
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
                        'Nombre del lugar: ${reservasProvider.nombreLugar!}',
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

class infocliente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reservasProvider =
        Provider.of<ReservasProvider>(context, listen: false);
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
                        'Nombre del destinatario: ${reservasProvider.primerNombre!}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
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
                      'Teléfono del destinatario: ${reservasProvider.primerTelefono!}',
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
                        'Nombre del contacto adicional: ${reservasProvider.segundoNombre!}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
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
                      'Teléfono alternativo: ${reservasProvider.segundoTelefono!}',
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
  CustomerCart(
      {required this.link_imagen,
      required this.nombre,
      required this.cantidad});

  final String link_imagen;
  final String nombre;
  final int cantidad;

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
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    link_imagen,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(Icons.error); // O una imagen de error
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 200,
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
                      ),
                    ]),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Row(children: [
                        Icon(
                          Icons.groups_sharp,
                          color: Color.fromARGB(246, 134, 129, 120),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '$cantidad Personas',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(246, 134, 129, 120),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class infoubicacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    late GoogleMapController mapController;
    LatLng? selectedLocation;
    final reservasProvider =
        Provider.of<ReservasProvider>(context, listen: false);
    if (reservasProvider.latitud != null && reservasProvider.longitud != null) {
      // Convierte latitud y longitud a LatLng
      selectedLocation =
          LatLng(reservasProvider.latitud!, reservasProvider.longitud!);
    }
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

class infoespecialidades extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reservasProvider =
        Provider.of<ReservasProvider>(context, listen: false);
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
              if (reservasProvider.mobiliario == true) ...[
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
              if (reservasProvider.blancos == true) ...[
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
              if (reservasProvider.personal == true) ...[
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
              if (reservasProvider.crsitaleria == true) ...[
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
              if (reservasProvider.mesero == true) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.person,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Meseros',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
              ],
              if (reservasProvider.chef == true) ...[
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
