import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/Empresa/api_imagenes.dart';
import 'package:cateringmid/Empresa/api_menuinfo.dart';
import 'package:cateringmid/Empresa/api_menus.dart';
import 'package:cateringmid/Empresa/api_service.dart';
import 'package:cateringmid/Empresa/api_menuinfo.dart';
import 'package:cateringmid/Empresa/empresa.dart';
import 'package:cateringmid/Favoritos/Api_misfavoritos.dart';
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
      home: Misfavoritospage(),
      
      debugShowCheckedModeBanner: false,
    );
  }
}

class Misfavoritospage extends StatefulWidget {

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<Misfavoritospage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final  Apimisfavoritos  favorito =  Apimisfavoritos ();
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
            favorito.fetchfavoritos()
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
                  title: const Text('Mis Favoritos'),
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
 
    ListView.builder(
    itemCount: favorito.misfavoritos.length +(isLoading ? 1 : 0),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      if (index < favorito.misfavoritos.length) {
        final misfavoritos = favorito.misfavoritos[index];
          return CustomerCart(
            id_empresa: misfavoritos.id_empresa,
            id_favorito: misfavoritos.idfavorito,
            empresa: misfavoritos.empresanombre,
            link: misfavoritos.empresalogo,
          
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
  )]
  ));

}

}


class CustomerCart extends StatelessWidget {
    CustomerCart({
      required this.id_empresa,
      required this.link,
      required this.empresa,
      required this.id_favorito
    });

  final String id_favorito;
  final String link;
  final String empresa;
  final String id_empresa;
  
  final  Apimisfavoritos  favorito =  Apimisfavoritos ();


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
                  builder: (context) => CompanyPage(id_empresa: id_empresa,)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Image.network(
                        link,
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
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 200,
                              child:
                              Expanded(child: 
                                Text(
                                  empresa,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                
                              ),
                              )
                            ),
                            const Spacer(),
                            Container(
                            width: 50,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.topCenter,
                            child: TextButton(
                            onPressed: () {
                              favorito.deletefavoritos(id: id_favorito, context: context);
                            },
                            child:
                             
                               Icon( Icons.delete_rounded, color:const Color(0xFF670A0A),size: 30,),
                             
                              
                            )),
                        ]
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


