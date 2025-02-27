import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/Reservas/reservacliente.dart';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:cateringmid/Reservas/reservaubicacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import '../Empresa/api_imagenes.dart';
import '../Empresa/api_menus.dart';
import '../Empresa/api_service.dart';
import '../home/afertas.dart';
import '../home/api_service.dart';

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
      home: MenuSelectPage(
        id_empresa: '1',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MenuSelectPage extends StatefulWidget {
  final String id_empresa;
  // Constructor con ambos parámetros
  const MenuSelectPage({
    Key? key,
    required this.id_empresa,
  }) : super(key: key);

  @override
  _selectmenu createState() => _selectmenu();
}

class _selectmenu extends State<MenuSelectPage> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final ReservaMenu reservamenu = ReservaMenu(); // Acceso a los menús seleccionados
 final MenusR menusr = MenusR(); // Donde se guardarán definitivamente

  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;
  bool _mobiliario = true;
  bool _blancos = true;
  bool _personal= true;
  bool _chef = true;
  bool _meseros = true;
  bool _cristaleria= true;
final Map<int, int> cantidades = {};
  @override
  void initState() {
    super.initState();
  }
void _siguiente() async {
  if(reservamenu.menu.isNotEmpty)
  {
  reservamenu.menu.forEach((menu) {
    menusr.add(
      idMenuEmpresa: menu.idMenuEmpresa,
      cantidad: cantidades[menu.idMenuEmpresa] ?? menu.minPersonas,
      costo: menu.precio,
      context: context,
    );
  });

  print(widget.id_empresa);
  Provider.of<ReservasProvider>(context, listen: false).actualizaradicionales(
    _mobiliario,
    _blancos,
    _personal,
    _cristaleria,
    _meseros,
    _chef,
  );

  print(widget.id_empresa);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Reserva(id_empresa: widget.id_empresa)),
  );
  }
  else 
  {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró un menú'),
          backgroundColor: Color(0xFF670A0A),
          duration: const Duration(seconds: 1), 
        ),
      );
  }
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
          future: Future.wait([
          ]),
          builder: (context, snapshot) {
            
            return Scaffold(
              appBar: AppBar(
            title: const Text('Reservacion'),
            backgroundColor: const Color(0xFF670A0A),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 90,),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              body:SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        
                        _bar(),
                        _paso(),
                        _menuinfo(),
                        _menus(),
                        const SizedBox(height: 20),
                        _servicios(),
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

Widget _button()
{
  return ElevatedButton(
  onPressed: () {
    _siguiente();

    },
    style: ElevatedButton.styleFrom(
      fixedSize: const Size(300, 50), // Ancho fijo de 250 y alto de 50
      backgroundColor:  const Color(0xFF670A0A),
      foregroundColor: const Color.fromARGB(255, 240, 239, 239),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      const Text('Continuar'),
      ],
    ),
  );
}

Widget _menus()
{
  return ListView.builder(
  itemCount: reservamenu.menu.length +(isLoading ? 1 : 0),
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemBuilder: (context, index) {
    if (index < reservamenu.menu.length) {
      final menu = reservamenu.menu[index];
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
                    width: 110,
                    height: 100,
                    child: Image.network(
                      menu.linkImagen, // Usa widget.link_imagen para acceder a las propiedades del widget
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
                        return const Icon(Icons.error);
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
                            child: Text(
                              menu.nombre, // Usa widget.nombre
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              reservamenu.eliminarPorId(context, menu.idMenuEmpresa); // Usa widget.idMenuEmpresa
                              menusr.eliminarPorId(context, menu.idMenuEmpresa);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuSelectPage(
                                          id_empresa: widget.id_empresa, // Usa widget.idEmpresa
                                        )),
                              );
                            },
                            icon: const Icon(Icons.remove),
                            color: const Color(0xFF670A0A),
                            iconSize: 35,
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (menu.minPersonas > 1) {
                                menu.minPersonas--;
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
                          '${menu.minPersonas}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(197, 112, 103, 103),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              menu.minPersonas++;
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
                    
                    ],
                  ),
                ),
              ],
            ),
          ),
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
);
}


Widget _menuinfo()
  {
  return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical:0 ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Text(
                  'Menus', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 25,
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
  
Widget _bar(){
  return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 70, vertical:30 ),
  child:  
    Row(
      children: [
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
                  color:  Colors.grey, // Estado actual
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
    
      ]
    )
  );
}

Widget _servicios()
  {
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical:0 ),
                child:
                Text(
                  'Servicios adicionales', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF670A0A),
                  ),
                ), 
              ),
          ]),
        ), 
      const SizedBox(height: 20),
      CheckboxListTile(
        title: Text('Mobiliario'),
        value: _mobiliario,
        onChanged: (bool? value) {
          setState(() {
            _mobiliario = value!;
          });
        },
        activeColor: Color(0xFF670A0A),
        controlAffinity: ListTileControlAffinity.leading,
      ),
      CheckboxListTile(
        title: Text('Blancos'),
        value: _blancos,
        onChanged: (bool? value) {
          setState(() {
            _blancos = value!;
          });
        },
        activeColor: Color(0xFF670A0A),
        controlAffinity: ListTileControlAffinity.leading,
      ),
      CheckboxListTile(
        title: Text('Personal'),
        value: _personal,
        onChanged: (bool? value) {
          setState(() {
            _personal = value!;
          });
        },
        activeColor: Color(0xFF670A0A),
        controlAffinity: ListTileControlAffinity.leading,
      ),
      CheckboxListTile(
        title: Text('Cristaleria'),
        value: _cristaleria,
        onChanged: (bool? value) {
          setState(() {
            _cristaleria = value!;
          });
        },
        activeColor: Color(0xFF670A0A),
        controlAffinity: ListTileControlAffinity.leading,
      ),
      CheckboxListTile(
        title: Text('Meseros'),
        value: _meseros,
        onChanged: (bool? value) {
          setState(() {
            _meseros = value!;
          });
        },
        activeColor: Color(0xFF670A0A),
        controlAffinity: ListTileControlAffinity.leading,

      ),
      CheckboxListTile(
        title: Text('Chef'),
        value: _chef,
        onChanged: (bool? value) {
          setState(() {
            _chef = value!;
          });
        },
        activeColor: Color(0xFF670A0A),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    ]
    );
  }
  
Widget _paso()
  {
  return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical:0 ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Paso 1 de 4', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 25,
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

