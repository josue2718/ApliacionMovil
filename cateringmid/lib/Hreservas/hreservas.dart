import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/Empresa/api_imagenes.dart';
import 'package:cateringmid/Empresa/api_menuinfo.dart';
import 'package:cateringmid/Empresa/api_menus.dart';
import 'package:cateringmid/Empresa/api_service.dart';
import 'package:cateringmid/Empresa/api_menuinfo.dart';
import 'package:cateringmid/Hreservas/apihreservas.dart';
import 'package:cateringmid/Hreservas/inforeservas.dart';
import 'package:cateringmid/home/afertas.dart';
import 'package:cateringmid/menu%20despegable/CustomDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import '../Reservas/reservamenu.dart';
import '../Reservas/selectmenu.dart';
import '../home/api_service.dart';
import '../home/home.dart';

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
      home: HreservaPage(),
      
      debugShowCheckedModeBanner: false,
    );
  }
}

class HreservaPage extends StatefulWidget {


  // Constructor con ambos parámetros
  const HreservaPage({
    Key? key,

  }) : super(key: key);

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<HreservaPage> {

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

  // Función para cargar más datos de forma asíncrona
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
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: Future.wait([
            apimireserva.fetchMenuinfoData()
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF670A0A),
                  backgroundColor: Colors.white,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: \${snapshot.error}'),
              );
            }
            return Scaffold(
               drawer: const CustomDrawer(),
                appBar: AppBar(
                  title: const Text('Mis Resevas'),
                  backgroundColor: const Color(0xFF670A0A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  toolbarHeight: 90,
                  actions: [
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificaciones')),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 30,
                      ),
                      label: Text(''),
                    ),
                  ],
                ),
              backgroundColor: Colors.white,
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _mireserva(),
                        
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  


Widget _mireserva()
{
  return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
        Container(
        alignment: Alignment.topLeft,
        child: Column(
          children: [
          Text(
            'Esta semana', // Usamos la variable que corresponde a la empresa
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF670A0A),
                ),
          ), 
        ]),
      ),
      Transform.translate(
  offset: Offset(0, -40), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
  child: 
    ListView.builder(
    itemCount: apimireserva.misreservas.length +(isLoading ? 1 : 0),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      if (index < apimireserva.misreservas.length) {
        final misreservas = apimireserva.misreservas[index];
          return CustomerCart(
          fecha :misreservas.fecha,
          hora: misreservas.hora,
          empresa: misreservas.Nempresa,
          id_reserva: misreservas.idreserva,
          
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
  ))]
  ));

}

}


class CustomerCart extends StatelessWidget {
    CustomerCart({
      required this.fecha,
      required this.hora,
      required this.empresa,
      required this.id_reserva
    });

  final String fecha;
  final String hora;
  final String empresa;
  final String id_reserva;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical:0 ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
          ),
          color: const Color.fromARGB(255, 255, 255, 255),
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => infohreserva(id_reserva: id_reserva),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              child:
                              Expanded(child: 
                                Text(
                                  empresa,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 2, // Ajusta el número de líneas según sea necesario
                              ),
                              )
                            ),
                            Container(
                            width: 100,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.topCenter,
                            child: TextButton(
                            onPressed: () {
                              
                            },
                            child:
                              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                              
                              Container(width: 10),
                              Text(
                                'Ver mas',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(246, 105, 96, 96),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                            ])),
                        )]
                        ),
                        SizedBox(height: 10),
                        Container(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                              Icon(
                                Icons.calendar_today,
                                color: Color.fromARGB(246, 134, 129, 120),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Fecha del evento: ${fecha}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(246, 134, 129, 120),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                          ),
                           SizedBox(height: 10),
                            Container(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                              Icon(
                                Icons.access_time_outlined,
                                color: Color.fromARGB(246, 134, 129, 120),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Hora: $hora',
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
            ),
          ),
    )
    );
  }
}


