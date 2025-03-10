import 'dart:convert';
import 'package:cateringmid/Reservas/reservamenu.dart';
import 'package:cateringmid/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ReservasProvider with ChangeNotifier {
  String? fecha;
  String? hora;
  String? primerNombre;
  String? segundoNombre;
  String? primerTelefono;
  String? segundoTelefono;
  bool enviado = true;
  bool aceptado = false;
  bool pago = false;
  bool preparando = false;
  bool enviando = false;
  bool completado = false;
  bool mobiliario = true;
  bool blancos = false;
  bool personal = false;
  bool crsitaleria = false;
  bool chef = false;
  bool mesero = false;
  double? latitud;
  double? longitud;
  String? direccion;
  String? nombreLugar;
  String? numCasa;
  String? referencias;
  double? costo;
  double? anticipo;

  void limpiar()
  {
  primerNombre = null;
  segundoNombre = null;
  primerTelefono = null;
  segundoTelefono = null;
  mobiliario = false;
  blancos = false;
  personal = false;
  crsitaleria = false;
  mesero =false;
  chef = false;
  direccion = null;
  nombreLugar = null;
  numCasa = null;
  referencias = null;
  latitud = null;
  longitud = null;
  notifyListeners();
  }

  void actualizardatosclienter(String nombre1, String nombre2, String telefono1, String telefono2, String nuevaFecha, String nuevaHora) {
    fecha = nuevaFecha;
    hora = nuevaHora;
    primerNombre = nombre1;
    segundoNombre = nombre2;
    primerTelefono = telefono1;
    segundoTelefono = telefono2;
    notifyListeners();
  }
void actualizaradicionales(bool Nmobiliario, bool Nblancos, bool Npersonal, bool Ncristaleria, bool Nmeseros, bool Nchef) {
    mobiliario = Nmobiliario;
    blancos = Nblancos;
    personal = Npersonal;
    crsitaleria = Ncristaleria;
    mesero = Nmeseros;
    chef = Nchef;
    notifyListeners();
  }
  // Método para actualizar la dirección
  void actualizarDireccion( String nombreLugarNuevo, String numCasaNuevo, String referenciasNueva) {
    nombreLugar = nombreLugarNuevo;
    numCasa = numCasaNuevo;
    referencias = referenciasNueva;
    notifyListeners();
  }

    void actualizarcostos( double ncosto, double nanticipo) {
    costo = ncosto;
    anticipo= nanticipo;
    notifyListeners();
  }
  void actualizarDireccionmap(String direccionNueva,double latitudN ,double longitudN) {
    direccion = direccionNueva;
    latitud = latitudN;
    longitud = longitudN;
    notifyListeners();
  }






  // Método para enviar la reserva
  Future<void> enviarReserva({required String empresa, required BuildContext context}) async {
    // Obtén los datos del proveedor antes de realizar la solicitud
    final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);
    MenusR reserva = MenusR();
    final ReservaMenu reservamenu = ReservaMenu();
    final prefs = await SharedPreferences.getInstance();
    final id_cliente = prefs.getString('id');
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {

    return;
  }

    // Verifica que id_cliente no sea nulo antes de usarlo
    if (id_cliente == null) {

      return; // Evita enviar la solicitud si el id_cliente es nulo
    }

   

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF670A0A),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        );
      },
    );
  

    final url = Uri.parse('https://cateringmidd.azurewebsites.net/api/Reservas');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "id_cliente": id_cliente,
        "id_empresa": empresa,
        "fecha":'${reservasProvider.fecha}T00:00:00Z',
        "hora": '${reservasProvider.hora}:00',
        "costo": reservasProvider.costo,
        "anticipo":reservasProvider.anticipo,
        "horas": "00:00:00",
        "contrato": "string",
        "mobiliario": reservasProvider.mobiliario,
        "blancos": reservasProvider.blancos,
        "personal": reservasProvider.personal,
        "cristaleria": reservasProvider.crsitaleria,
        "chef": reservasProvider.chef,
        "meseros": reservasProvider.mesero,
        "cantidadmeseros": 0,
        "menu_Reservas": reserva.menureserva.map((menu) => menu.toJson()).toList(),
        "reserva_Info_Clientes": [
          {
            "primer_nombre": reservasProvider.primerNombre ?? "",
            "segundo_nombre": reservasProvider.segundoNombre ?? "",
            "primer_telefono": reservasProvider.primerTelefono ?? "",
            "segundo_telefono": reservasProvider.segundoTelefono ?? ""
          }
        ],
        "estatus_Reservas": [
          {
            "enviado": reservasProvider.enviado,
            "aceptado": reservasProvider.aceptado,
            "pago": reservasProvider.pago,
            "preparando": reservasProvider.preparando,
            "enviando": reservasProvider.enviando,
            "completado": reservasProvider.completado
          }
        ],
        "reserva_direccions": [
          {
            "latitud": reservasProvider.latitud ?? 0,
            "longitud": reservasProvider.longitud ?? 0,
            "direccion": reservasProvider.direccion ?? "",
            "nombre_lugar": reservasProvider.nombreLugar ?? "",
            "num_casa": reservasProvider.numCasa ?? "",
            "referencias": reservasProvider.referencias ?? ""
          }
        ]
      }),
    );

    if (response.statusCode == 201) {
      reserva.limpiar();
      reservamenu.limpiar();
      reservasProvider.limpiar();
      Navigator.pop(context);
      showDialog(
      context: context,
      builder: (context) {
        return  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical:200 ),
              child : Card(
                color: const Color.fromARGB(255, 255, 255, 255),
            child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                  'assets/LOGOROJO.png',
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
              ),
              SizedBox(height: 50),
                    Text(
                      'RESERVA ENVIADA',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF670A0A),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                     SizedBox(height: 10),
                    Text(
                      'Espera tu confirmación',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 50),
                  TextButton(
                onPressed: () {

                 Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),);
                },
               style: ElevatedButton.styleFrom(
                    fixedSize: const Size(250, 50), // Ancho fijo de 250 y alto de 50
                    backgroundColor:  const Color(0xFF670A0A),
                    foregroundColor: const Color.fromARGB(255, 240, 239, 239),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Regresar'),
                    ],
                  ),
                
              ),                
                
            ]
            )
            )
            
              
        );
 }
 );
  

    } else {
     Navigator.pop(context);
      showDialog(
      context: context,
      builder: (context) {
        return  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical:200 ),
              child : Card(
                color: const Color.fromARGB(255, 255, 255, 255),
            child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                  'assets/LOGOROJO.png',
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
              ),
              SizedBox(height: 50),
                    Text(
                      'Error en enviar reserva',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF670A0A),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                     SizedBox(height: 10),
                    Text(
                      'vuelve a intentarlo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 50),
                  TextButton(
                onPressed: () {

                 Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),);
                },
               style: ElevatedButton.styleFrom(
                    fixedSize: const Size(250, 50), // Ancho fijo de 250 y alto de 50
                    backgroundColor:  const Color(0xFF670A0A),
                    foregroundColor: const Color.fromARGB(255, 240, 239, 239),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Regresar'),
                    ],
                  ),
                
              ),                
                
            ]
            )
            )
            
              
        );
 }
 );
    }
  }
}

