import 'dart:async';
import 'package:cateringmid/Empresa/menu.dart';
import 'package:shimmer/shimmer.dart';
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
 final ReservaMenu reservamenu = ReservaMenu(); // Acceso a los menús seleccionados
 final MenusR menusr = MenusR(); // Donde se guardarán definitivamente
    bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;
  int cantidad=0;
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
            if (snapshot.connectionState == ConnectionState.waiting && !isLoading) {
              isLoading= true;
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
          
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -40),
                  child: ListView.builder(
                    itemCount: 5, // Número de elementos de esqueleto para Gastronomia
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
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
                                    const SizedBox(height: 5),
                                    Container(
                                      height: 13,
                                      width: 150,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMenuinfo() {
   return Transform.translate(
    offset: Offset(0, -50), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
    child: ListView.builder(
      itemCount: apimenuinfo.menuinfo.length ,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimenuinfo.menuinfo.length) {
          final menuinfo = apimenuinfo.menuinfo[index];
          return Column(
            children: [
              cardsofertas(link_imagen: menuinfo.linkImagen),
              nombremenu(
                nombre: menuinfo.nombre, 
                min: menuinfo.minPersonas,
                max: menuinfo.maxPersonas, idEmpresa: menuinfo.idEmpresa, idMenuEmpresa: menuinfo.idMenuEmpresa, precio: menuinfo.precio, link_imagen: menuinfo.linkImagen,
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
    itemCount: apimenuinfo.gastronomia.length ,
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

Widget _bottomBar(BuildContext context) {
    final ReservaMenu reservamenu =
        ReservaMenu(); // Acceso a los menús seleccionados
    
   return  ListView.builder(
      itemCount: apimenuinfo.menuinfo.length ,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < apimenuinfo.menuinfo.length) {
     
final menu = apimenuinfo.menuinfo[index];
if(cantidad == 0){
 cantidad = menu.minPersonas;
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
                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all( // Use Border.all for a uniform border
                      color: Color.fromARGB(255, 196, 196, 196),
                      width: 3.0, // Optional: Set the border width
                    ),
                  ),
               
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente el Column
    crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child:Row(
  mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente el Column
    crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (menu.minPersonas < cantidad) {
                                cantidad--;
                              }
                            });
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Color.fromARGB(197, 112, 103, 103),
                            size: 25,
                          ),
                        ),
                        Text(
                          '${cantidad}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(197, 112, 103, 103),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                               if (menu.maxPersonas>  cantidad) {
                              cantidad++;
                               }
                            });
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Color.fromARGB(197, 112, 103, 103),
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                        )
                      ],
                    )),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                     
                    setState(() {
                    reservamenu.add(context: context, idMenuEmpresa: menu.idMenuEmpresa, idEmpresa: menu.idEmpresa, nombre: menu.nombre, linkImagen: menu.linkImagen, precio: menu.precio, minPersonas: menu.minPersonas, maxPersonas: menu.maxPersonas, cantidad:cantidad);
                  });

          

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
                      Text('Añadir'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
});
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
        height: 360,
        width: 450,
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
           
        ],
      ),
    );
  }
}
