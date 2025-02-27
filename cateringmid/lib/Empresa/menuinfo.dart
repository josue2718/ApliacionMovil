import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/Empresa/api_gastronomia.dart';
import 'package:cateringmid/Empresa/api_imagenes.dart';
import 'package:cateringmid/Empresa/api_menuinfo.dart';
import 'package:cateringmid/Empresa/api_menus.dart';
import 'package:cateringmid/Empresa/api_service.dart';
import 'package:cateringmid/Empresa/api_menuinfo.dart';
import 'package:cateringmid/home/afertas.dart';
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
      home: MenuinfoPage(
        id_empresa: '1', id_menu_empresa: '',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MenuinfoPage extends StatefulWidget {
  final String id_empresa;
  final String id_menu_empresa;

  // Constructor con ambos parámetros
  const MenuinfoPage({
    Key? key,
    required this.id_empresa,
    required this.id_menu_empresa
  }) : super(key: key);

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<MenuinfoPage> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final Apiempresaclass apiempresaclass =Apiempresaclass(); // Instancia de Apiclass
  final Apiclassdesucuentos apides = Apiclassdesucuentos();
  final ScrollController _scrollController = ScrollController();
  final Apiimagenes_Empresasclass apiimagen = Apiimagenes_Empresasclass();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final Apimenuclass apimenu = Apimenuclass();
 final Apiclass api = Apiclass();
 final Apimenuinfoclass  apimenuinfo = Apimenuinfoclass();
  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;
  
  bool personalizar = false;

  @override
  void initState() {
    super.initState();
    checkAndReload();
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
            apiempresaclass.fetchEmpresaIDData(widget.id_empresa),
            apimenu.fetchMenusEmpresaData(widget.id_empresa),
            apiimagen.fetchImagenEmpresaData(widget.id_empresa),
            apimenuinfo.fetchMenuinfoData(widget.id_menu_empresa),
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
            if (apiempresaclass.empresas.isEmpty) {
              
            }

            return Scaffold(
              backgroundColor: Colors.white,
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildCarousel(),
                        _buildMenuinfo(),
                        Transform.translate(
                        offset: Offset(0, -50), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
                        child: 
                        _platillo(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: _buildFloatingActionButton(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    if (apiimagen.imagenes_Empresas.isEmpty) return SizedBox();
    return CarouselSlider.builder(
      itemCount: apiimagen.imagenes_Empresas.length,
      itemBuilder: (context, index, realIndex) {
        final imagen = apiimagen.imagenes_Empresas[index];
        return cardsofertas(link_imagen: imagen.link_imagen);
      },
      options: CarouselOptions(
        height: 350,
        viewportFraction: 1.0,
        enlargeCenterPage: true,
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

  Widget _buildMenuinfo() {
   return Transform.translate(
    offset: Offset(0, -40), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
    child: ListView.builder(
      itemCount: apimenuinfo.menuinfo.length + (isLoading ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimenuinfo.menuinfo.length) {
          final menuinfo = apimenuinfo.menuinfo[index];
          return Column(
            children: [
              nombremenu(
                nombre: menuinfo.nombre, 
                min: menuinfo.minPersonas,
                max: menuinfo.maxPersonas, idEmpresa: menuinfo.idEmpresa, idMenuEmpresa: menuinfo.idMenuEmpresa, precio: menuinfo.precio, link_imagen: menuinfo.linkImagen,
                ),
              informacionmenu(
                descripcion: menuinfo.descripcion,
                link_imagen: menuinfo.linkImagen,
                precio:  menuinfo.precio,
                mobiliario: menuinfo.mobiliario,
                blancos: menuinfo.blancos,
                personal: menuinfo.personal,
                cristaleria: menuinfo.cristaleria,
                chef: menuinfo.chef,
                meseros: menuinfo.meseros,
              ),
            ]
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    )
   );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
    final listaEmpresas = apiempresaclass.empresas; // Asumiendo que apiempresaclass.empresas es List<Empresa> 
      if (listaEmpresas.isNotEmpty) { // Verifica que la lista no esté vacía
        final idEmpresa = listaEmpresas[0].idEmpresa; // Obtiene el idEmpresa del primer elemento (índice 0)

          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => MenuSelectPage(id_empresa: idEmpresa),
          ),
          );
        }
       else {

      }
        },
    
    backgroundColor:Color(0xFF670A0A) ,
    child: Icon(
      Icons.add_circle_outline_sharp ,
      color: Color.fromARGB(255, 255, 255, 255),
    ),
    );
  }

Widget _platillo()
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
            'Gastronomia', // Usamos la variable que corresponde a la empresa
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
    itemCount: apimenuinfo.gastronomia.length +(isLoading ? 1 : 0),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      if (index < apimenuinfo.gastronomia.length) {
        final gastronomia = apimenuinfo.gastronomia[index];
          return CustomerCart(
          link_imagen: gastronomia.linkImagen,
          nombre : gastronomia.nombre,
          descripcion: gastronomia.descripcion,
          
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


class cardsofertas extends StatelessWidget {
  cardsofertas({required this.link_imagen});
  final String link_imagen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
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
        ),
      ),
    );
  }
}

class CustomerCart extends StatelessWidget {
    CustomerCart({
      required this.link_imagen,
      required this.nombre,
      required this.descripcion,
    });

  final String link_imagen;
  final String nombre;
  final String descripcion;


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
                                Text(
                                  nombre,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 2, // Ajusta el número de líneas según sea necesario
                              ),
                            ),
                            
                          ]
                        ),
                        SizedBox(height: 5),
                        Container(
                              width: 200,
                              child:
                                Text(
                                  descripcion,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                         color: Color.fromARGB(246, 134, 129, 120),
                                      ),
                                  maxLines: 2, // Ajusta el número de líneas según sea necesario
                              ),
                            ),
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



class informacionmenu extends StatelessWidget {
  informacionmenu(
      {required this.descripcion,
      required this.link_imagen,
      required this.precio,
      required this.mobiliario,
      required this.blancos ,
      required this.personal ,
      required this.cristaleria,
      required this.meseros ,
      required this.chef,
});
  
  final String link_imagen;
  final String descripcion;
  final double precio;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 0),
                Text(
                  'Descripcion', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF670A0A),
                      ),
                ),
                 Text(
                  descripcion, // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(246, 134, 129, 120),
                      ),
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
                 if(mobiliario== true)...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
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
                if(blancos== true)...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
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
                if(personal== true)...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
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
                if(cristaleria== true)...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
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
                if(meseros== true)...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
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
                if(chef== true)...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
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

class nombremenu extends StatelessWidget {
  nombremenu({
    required this.nombre,
    required this.min,
    required this.max,
    required this.idEmpresa,
    required this.idMenuEmpresa,
    required this.precio,
    required this.link_imagen,
  });

  final String nombre;
  final int min;
  final int max;
  final String idEmpresa;
  final String idMenuEmpresa;
  final String link_imagen;
  final double precio;
  final ReservaMenu reservamenu = ReservaMenu();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to the top of the row
        children: [
          Container(
            width: 320,
            child: 
          Expanded( // Use Expanded to allow text to wrap
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Color(0xFF6A77E2E),
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true, // Key for text wrapping
                  maxLines: 1, // Limita el texto a una sola línea
                                  overflow: TextOverflow.ellipsis
                ),
                Row(
                  children: [
                    Icon(
                      Icons.groups_sharp,
                      color: Color.fromARGB(246, 134, 129, 120),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '$min a $max Personas',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(246, 134, 129, 120),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
            const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF670A0A),
              borderRadius: BorderRadius.circular(50),
            ),
            width: 55,
            height: 55,
            child: IconButton(
              onPressed: () {
                reservamenu.add(
                  context: context,
                  idEmpresa: idEmpresa,
                  idMenuEmpresa: idMenuEmpresa,
                  linkImagen: link_imagen,
                  nombre: nombre,
                  minPersonas: min,
                  maxPersonas: max,
                  precio: precio,
                );
              },
              icon: const Icon(Icons.add_outlined),
              color: const Color.fromARGB(255, 255, 255, 255),
              iconSize: 35,
            ),
          ),
        ],
      ),
    );
  }
}
