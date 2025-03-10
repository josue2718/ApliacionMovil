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


class AdicionalesPage extends StatefulWidget {
  final String id_empresa;
  // Constructor con ambos parámetros
  const AdicionalesPage({
    Key? key,
    required this.id_empresa,
  }) : super(key: key);

  @override
  _selectmenu createState() => _selectmenu();
}

class _selectmenu extends State<AdicionalesPage> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final ReservaMenu reservamenu = ReservaMenu(); // Acceso a los menús seleccionados
 final MenusR menusr = MenusR(); // Donde se guardarán definitivamente
  int precio=0;
  int anticipo=0;
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

