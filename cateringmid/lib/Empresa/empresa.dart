import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/Empresa/api_imagenes.dart';
import 'package:cateringmid/Empresa/date.dart';
import 'package:cateringmid/Empresa/api_menus.dart';
import 'package:cateringmid/Empresa/api_service.dart';

import 'package:cateringmid/Empresa/menu.dart';
import 'package:cateringmid/Favoritos/api_favoritos.dart';
import 'package:cateringmid/Reservas/reservamenu.dart';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Reservas/selectmenu.dart';
import '../home/api_service.dart';

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
      home: CompanyPage(
        id_empresa: '1',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CompanyPage extends StatefulWidget {
  final String id_empresa;

  // Constructor con ambos parámetros
  const CompanyPage({
    Key? key,
    required this.id_empresa,
  }) : super(key: key);

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<CompanyPage> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final Apiempresaclass apiempresaclass =
      Apiempresaclass(); // Instancia de Apiclass
  final Apiimagenes_Empresasclass apiimagen = Apiimagenes_Empresasclass();
  final Apimenuclass apimenu = Apimenuclass();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final Apiclass api = Apiclass(); // Instancia de Apiclass
  final Apidateempresaclass apidate = Apidateempresaclass();
  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  MenusR reserva = MenusR();
  final ReservaMenu reservamenu = ReservaMenu();


  @override
  void initState() {
    super.initState();
    checkAndReload();
    reserva.limpiar();
    reservamenu.limpiar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reservasProvider =
          Provider.of<ReservasProvider>(context, listen: false);
      reservasProvider.limpiar(); // Limpia los datos
    });
  }

  void checkAndReload() async {
    if (apiempresaclass.empresas.isEmpty) {
      pageNumber = 1;
      await apiempresaclass.fetchEmpresaIDData(widget.id_empresa);
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(
              () {}); // Esto actualiza la UI sin romper la fase de construcción
        }
      });
      print('Recargando página porque no hay datos');
    }
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose(); // Libera el recurso
    _scrollController.dispose(); // Libera el controlador de scroll
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      pageNumber++;
      hasMore = true;
    });
  }

  Future<void> _showCalendarDialog(BuildContext context) async {
    // Lista de fechas a resaltar

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Usa un AlertDialog para el diálogo
          content: SizedBox(
            // Ajusta el tamaño del calendario
            width: 300,
            height: 400,
            child: TableCalendar(
                calendarFormat: _calendarFormat,
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2030, 12, 30),
                selectedDayPredicate: (day) {
                  return apidate.date
                      .map((dateObj) => DateTime.parse(
                          dateObj.fecha)) // Convierte el String a DateTime
                      .any((date) => isSameDay(date,
                          day)); // Compara si alguna fecha coincide con 'day'// Verifica si alguna fecha coincide con 'day'
                },
                calendarStyle: CalendarStyle(
                  // Estilo general para todos los días
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF670A0A), // Color para el día de hoy
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 241, 184,
                        184), // Color para los días seleccionados
                    shape: BoxShape.circle,
                  ),
                )),
          ),
        );
      },
    );
  }

  void _llamarCalendario() {
    _showCalendarDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: FutureBuilder(
          future: Future.wait([
            apiempresaclass.fetchEmpresaIDData(widget.id_empresa),
            apiimagen.fetchImagenEmpresaData(widget.id_empresa),
            apimenu.fetchMenusEmpresaData(widget.id_empresa),
            apidate.fetchEmpresaIDData(widget.id_empresa)
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF670A0A),
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \${snapshot.error}'));
            }
            if (apiempresaclass.empresas.isEmpty) {}
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildCarouselempresa(),
                        _buildeempresa(),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: _button(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarouselempresa() {
    if (apiimagen.imagenes_Empresas.isNotEmpty) ;
    return CarouselSlider.builder(
      itemCount: apiimagen.imagenes_Empresas.length,
      itemBuilder: (context, index, realIndex) {
        final imagen = apiimagen.imagenes_Empresas[index];
        return imagenesempresa(link_imagen: imagen.link_imagen);
      },
      options: CarouselOptions(
        height: 350,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) {
          _currentIndexNotifier.value = index;
        },
      ),
    );
  }

  Widget _buildeempresa() {
    return Transform.translate(
        offset: Offset(
            0, -90), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
        child: ListView.builder(
          controller: _scrollController,
          itemCount: apiempresaclass.empresas.length + (isLoading ? 1 : 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index < apiempresaclass.empresas.length) {
              final empresa = apiempresaclass.empresas[index];
              return Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  // Usamos un Column para mostrar las tarjetas verticalmente
                  children: [
                    favorito(
                      link_logo: empresa.linkLogo,
                      nombre: empresa.nombre, 
                      id_empresa: widget.id_empresa,
                      
                    ),
                    nombreempresa(
                      nombre: empresa.nombre,
                      min: empresa.minPersonas,
                      max: empresa.maxPersonas,
                      oncalendar: _llamarCalendario,
                    ),
                    propetario(
                      link_logo: empresa.linkLogo,
                      nombre: empresa.nombrepropietario,
                      apellido: empresa.apellidopropietario,
                      estrellas: empresa.estrellas
                    ),
                    informacionempresa(
                      link_logo: empresa.linkLogo,
                      nombre: empresa.nombre,
                      informacion: empresa.informacion,
                      zona: empresa.zona,
                      ciudad: empresa.ciudad,
                      max: empresa.maxPersonas,
                      id_emp: empresa.idEmpresa,
                      mobiliario: empresa.mobiliario,
                      blancos: empresa.blancos,
                      personal: empresa.chef,
                      cristaleria: empresa.cristaleria,
                      meseros: empresa.meseros,
                      chef: empresa.chef,
                      vyl: empresa.vyl,
                      ubicacion: empresa.direccion,
                      horario: empresa.horario,
                      premin: empresa.premin,
                    ),
                    _infoservicios(),
                    const SizedBox(height: 5),
                    _buildeespecialidades(),
                    Menuinfo(
                      id_emp: empresa.idEmpresa,
                    ),
                    Container(
                        constraints: const BoxConstraints(
                          maxWidth: 3300,
                          maxHeight: 150,
                        ),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          shape: BoxShape.circle,
                        ),
                        child: //menu
                            ListView.builder(
                          scrollDirection:
                              Axis.horizontal, // <-- Esta línea es la clave
                          shrinkWrap: true, // Solo si es necesario
                          itemCount: min(10, apimenu.menu.length),
                          //physics: const NeverScrollableScrollPhysics(), // Descomentar para permitir scroll
                          itemBuilder: (context, index) {
                            if (index < apimenu.menu.length) {
                              final menu = apimenu.menu[index];
                              return imagenesmenu(
                                link_imagen: menu.linkImagen,
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
                        )),
                    datosubicacion(
                      latitud: empresa.latitud,
                      longitud: empresa.longitud,
                    )
                  ],
                ),
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
        ));
  }

  Widget _infoservicios() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Container(
          alignment: Alignment.topLeft,
          child: Text(
            'Especialidades', // Usamos la variable que corresponde a la empresa
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF670A0A),
                ),
          ),
        ));
  }

  Widget _buildeespecialidades() {
    return Transform.translate(
        offset:
            Offset(0, 0), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
        child: ListView.builder(
          controller: _scrollController,
          itemCount: apiempresaclass.servicios.length + (isLoading ? 1 : 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index < apiempresaclass.servicios.length) {
              final servicios = apiempresaclass.servicios[index];
              return Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    informacionespecialidades(
                      id: servicios.id_tipo,
                    ),
                  ],
                ),
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
        ));
  }

  Widget _button() {
    return FloatingActionButton(
      //onPressed: () => _selectDate(context),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MenuSelectPage(id_empresa: widget.id_empresa),
            ));
      },

      backgroundColor: Color(0xFF670A0A),
      child: Icon(
        Icons.add_circle_outline_sharp,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }


}

 class favorito extends StatelessWidget {
    favorito({
    required this.link_logo,
    required this.nombre,
    required this.id_empresa
  });
  final String link_logo;
  final String nombre;
  final String id_empresa;


 final Favoritos favoritos = Favoritos();
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(150, -20),
        child: Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(218, 255, 255, 255),
                borderRadius: BorderRadius.circular(50)),
            width: 55,
            height: 55,
            child: IconButton(
              onPressed: () {
                favoritos. gardarfavorito(context: context, empresa: id_empresa, nombre: nombre);
              },
              icon: const Icon(
                  Icons.favorite_outline_rounded), // Usa un icono de calendario
              color: const Color.fromARGB(255, 121, 121, 121),
              iconSize: 35,
            )));
  }
}
class datosubicacion extends StatelessWidget {
  datosubicacion({
    required this.latitud,
    required this.longitud,
  });
  final double latitud;
  final double longitud;
  @override
  Widget build(BuildContext context) {
    LatLng? selectedLocation;
    selectedLocation = LatLng(latitud!, longitud!);
    return Padding(
        padding: const EdgeInsets.all(15),
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
                  elevation: 0,
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

class propetario extends StatelessWidget {
  propetario({
    required this.link_logo,
    required this.nombre,
    required this.apellido,
    required this.estrellas,
  });
  final String link_logo;
  final String nombre;
  final String apellido;
  final int estrellas;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(120),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    link_logo,
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
              Container(
                  width: 200,
                child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${nombre} ${apellido}', // Usamos la variable que corresponde a la empresa
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF670A0A),
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Dueño del Catering',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 1),
                  ],
                ),
                ),
              ),
              const Spacer(),
              Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.star_rounded ,
                            color: Color(0xFF6A77E2E),
                            size:40,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${estrellas}',
                        style: const TextStyle(
                          fontSize: 28,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                  ),
            ],
          ),
        ]));
  }
}

class informacionempresa extends StatelessWidget {
  informacionempresa(
      {required this.link_logo,
      required this.nombre,
      required this.informacion,
      required this.max,
      required this.id_emp,
      required this.ubicacion,
      required this.horario,
      this.mobiliario = false,
      this.blancos = false,
      this.personal = false,
      this.cristaleria = false,
      this.meseros = false,
      this.chef = false,
      this.vyl = false,
      required this.zona,
      required this.ciudad,
      required this.premin});

  final String link_logo;
  final String nombre;
  final String informacion;
  final String ubicacion;
  final String horario;
  final int max;
  final String id_emp;
  final bool mobiliario;
  final bool blancos;
  final bool personal;
  final bool cristaleria;
  final bool meseros;
  final bool chef;
  final bool vyl;
  final String zona;
  final String ciudad;
  final int premin;

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
                const SizedBox(height: 0),
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      horario,
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
                        ubicacion,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(246, 134, 129, 120),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 15),
                Text(
                  'Informacion', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF670A0A),
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  informacion,
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                ),
                SizedBox(height: 10),
                Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: 
                      Text(
                        'Zona(s) de servicio: ${zona}',
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                      ),
                    ]),
                  ),
                  SizedBox(height: 7),
                Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: 
                      Text(
                        'Ciudad principal: ${ciudad}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                      ),
                    ]),
                  ),
                   const SizedBox(height: 7),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.room_service,
                        size: 23,
                        color: Color.fromARGB(246, 134, 129, 120),
                        
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: 
                      Text(
                        'Menús desde: \$${premin}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                      ),
                    ]),
                  ),
                const SizedBox(height: 15),
                Text(
                  '¿Que servicios ofrecemos?', // Usamos la variable que corresponde a la empresa
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
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
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
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
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
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
                        'Meseros',
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                    ]),
                  ),
                ],
                if (vyl == true) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.wine_bar,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Vinos y Licores',
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class nombreempresa extends StatelessWidget {
  nombreempresa(
      {required this.nombre,
      required this.min,
      required this.max,
      required this.oncalendar});
  final Function() oncalendar;
  final String nombre;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 330,
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Color(0xFF6A77E2E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                      decoration: BoxDecoration(
                          color: Color(0xFF670A0A),
                          borderRadius: BorderRadius.circular(50)),
                      width: 55,
                      height: 55,
                      child: IconButton(
                        onPressed: () {
                          oncalendar();
                        },
                        icon: const Icon(Icons
                            .calendar_today_outlined), // Usa un icono de calendario
                        color: const Color.fromARGB(255, 255, 255, 255),
                        iconSize: 25,
                      ))
                ]),
                Row(children: [
                  Icon(
                    Icons.groups_sharp,
                    color: Color.fromARGB(197, 112, 103, 103),
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$min a $max personas',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(197, 112, 103, 103),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ]));
  }
}

class imagenesempresa extends StatelessWidget {
  imagenesempresa({required this.link_imagen});
  final String link_imagen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
        child: SizedBox(
          child: Image.network(
            link_imagen,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center();
            },
            errorBuilder: (context, object, stackTrace) {
              return const Icon(Icons.error); // O una imagen de error
            },
          ),
        ));
  }
}

class Menuinfo extends StatelessWidget {
  Menuinfo({required this.id_emp});
  final String id_emp;
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
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(children: [
                    Text(
                      'Menus y Cartas', // Usamos la variable que corresponde a la empresa
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF670A0A),
                          ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                        width: 100,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.topCenter,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MenuPage(id_empresa: id_emp),
                              ),
                            );
                          },
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(width: 10),
                                Text(
                                  'Ver mas',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(246, 105, 96, 96),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]),
                        )),
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

class imagenesmenu extends StatelessWidget {
  imagenesmenu({required this.link_imagen});
  final String link_imagen;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color.fromARGB(255, 255, 255, 255),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: InkWell(
            onTap: () {
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyPage(id_empresa: id_emp),
                ),
              );*/
            },
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 120,
                      height: 200,
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
                          return const Icon(
                              Icons.error); // O una imagen de error
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class informacionespecialidades extends StatelessWidget {
  informacionespecialidades({
    required this.id,
  });
  final int id;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 1),
                if (id == 1) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.room_service,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Bodas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 1),
                if (id == 2) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.room_service,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'XV años',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 1),
                if (id == 3) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.room_service,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Eventos',
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                    ]),
                  ),
                ],
                if (id == 4) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.room_service,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Cumpleaños',
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 1),
                if (id == 5) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Icon(
                        Icons.room_service,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Otros',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
