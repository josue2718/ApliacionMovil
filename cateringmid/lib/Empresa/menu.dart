import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/Empresa/api_imagenes.dart';
import 'package:cateringmid/Empresa/api_menus.dart';
import 'package:cateringmid/Empresa/api_service.dart';
import 'package:cateringmid/Empresa/menuinfo.dart';
import 'package:cateringmid/home/afertas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shimmer/shimmer.dart';
import '../Reservas/reservamenu.dart';
import '../Reservas/selectmenu.dart';
import '../home/api_service.dart';
import '../home/home.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data with Infinite Scroll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
      ),
      home: MenuPage(
        id_empresa: '1',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MenuPage extends StatefulWidget {
  final String id_empresa;

  // Constructor con ambos parámetros
  const MenuPage({
    Key? key,
    required this.id_empresa,
  }) : super(key: key);

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<MenuPage> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final Apiempresaclass apiempresaclass =Apiempresaclass(); // Instancia de Apiclass
  final Apiclassdesucuentos apides = Apiclassdesucuentos();
  final ScrollController _scrollController = ScrollController();
  final Apiimagenes_Empresasclass apiimagen = Apiimagenes_Empresasclass();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final Apimenuclass apimenu = Apimenuclass();
 final Apiclass api = Apiclass(); // Instancia de Apiclass
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
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingShimmer(); 
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
                        _buildMenuList(),
                      ],
                    ),
                  ),
                ),
              ),
                bottomNavigationBar: _bottomBar(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 350,
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ListView.builder(
            itemCount: 5, // Número de elementos de esqueleto
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 110,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: 200,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 16,
                              width: 150,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 16,
                              width: 100,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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

  Widget _buildMenuList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Container(
        alignment: Alignment.center,
        child: Column(
          children: [
          Text(
            'Menus', // Usamos la variable que corresponde a la empresa
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color:  Color(0xFF6A77E2E),
                ),
          ), 
        ]),
      ),
     Transform.translate(
  offset: Offset(0, -40), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
  child: ListView.builder(
      itemCount: apimenu.menu.length + (isLoading ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimenu.menu.length) {
          final menu = apimenu.menu[index];
          return CustomerCart(
            idEmpresa: menu.idEmpresa,
            idMenuEmpresa: menu.idMenuEmpresa,
            link_imagen: menu.linkImagen,
            nombre : menu.nombre,
            descripcion : menu.descripcion,
            min : menu.minPersonas,
            max : menu.maxPersonas,
            precio: menu.precio,
            
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    ))
    ]
    );
  }

  

Widget _bottomBar(BuildContext context) {
    final ReservaMenu reservamenu =
        ReservaMenu(); // Acceso a los menús seleccionados
    final MenusR menusr = MenusR(); // Donde se guardarán definitivamente
    if (reservamenu.menu.isEmpty) {
      return SizedBox.shrink(); // No muestra nada si no hay menús seleccionados
    }
    return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width:
                  2.0, // Reduje el grosor del borde para que la sombra sea más notoria
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(158, 158, 158, 1)
                  .withOpacity(0.5), // Color de la sombra con opacidad
              spreadRadius: 5, // Radio de expansión de la sombra
              blurRadius: 5, // Radio de desenfoque de la sombra
              offset: Offset(
                  0, 3), // Desplazamiento de la sombra (horizontal, vertical)
            ),
          ],
        ),
        child: BottomAppBar(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Container(
                    width: 150,
                    child: Column(
                      children: [
                        Expanded(
                          child: Text(
                              'Menus seleccionados: ${reservamenu.menu.length} ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: 18,
                                    color: Color.fromARGB(246, 0, 0, 0),
                                  )),
                        )
                      ],
                    )),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MenuSelectPage(id_empresa: widget.id_empresa),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 45),
                    backgroundColor: const Color.fromRGBO(103, 10, 10, 1),
                    foregroundColor: const Color.fromARGB(255, 240, 239, 239),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Reserva'),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      required this.idEmpresa,
      required this.idMenuEmpresa,
      required this.link_imagen,
      required this.nombre,
      required this.descripcion,
      required this.min,
      required this.max,
      required this.precio
    });
  final String idEmpresa;
  final String idMenuEmpresa;
  final String link_imagen;
  final String nombre;
  final String descripcion;
  final int min;
  final int max;
  final double precio;
  final ReservaMenu reservamenu = ReservaMenu();

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
                                PageRouteBuilder(
                                  transitionDuration: Duration(milliseconds: 500), // Duración de la animación
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                    MenuinfoPage(id_empresa: idEmpresa, id_menu_empresa: idMenuEmpresa),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(0.0, 1.0); // Desde abajo
                                    const end = Offset.zero; // A su posición normal
                                    const curve = Curves.easeInOut; // Animación suave

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 110,
                      height: 100,
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
                            const Spacer(),

                            IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration(milliseconds: 500), // Duración de la animación
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                    MenuinfoPage(id_empresa: idEmpresa, id_menu_empresa: idMenuEmpresa),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(0.0, 1.0); // Desde abajo
                                    const end = Offset.zero; // A su posición normal
                                    const curve = Curves.easeInOut; // Animación suave

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },

                            icon: const Icon(Icons.add_outlined ), // Usa un icono de calendario
                            color: const Color(0xFF670A0A),
                            iconSize: 35, // Usa iconSize en lugar de size
                          ),
                          ]
                        ),
                        Row
                        (children: [
                          Icon(
                            Icons.groups_sharp ,
                           color: Color.fromARGB(197, 112, 103, 103),
                            size:25,
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
                        SizedBox(height: 2),
                         Row
                        (children: [
                          Icon(
                            Icons.room_service ,
                           color: Color.fromARGB(197, 112, 103, 103),
                            size:25,
                          ),
                          SizedBox(width: 10),
                          Text(
                           'Precio: \$${precio}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(197, 112, 103, 103),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                        SizedBox(height: 5),
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



