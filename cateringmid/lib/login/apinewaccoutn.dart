import 'dart:convert';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../cache.dart';
import '../home/home.dart';

class CrearcuentaProvider with ChangeNotifier {
  String? nombre;
  String? apellido;
  String? telefono;
  String? correo;
  String? password;
  String? confirpassword;
  String? imagen64;
  String? nameimagen;
  double? latidud;
  double? longitud;

  // Servicio para guardar el token
  final PreferencesService _preferencesService = PreferencesService();

  // Método para actualizar los datos del cliente
  void actualizardato(String Nnombre, String Napellido, String Ntelefono, String Ncorreo, String Npassword, String Nconfirpassword, String Nimagen64, String  Nnameimagen) {
    nombre = Nnombre;
    apellido = Napellido;
    telefono = Ntelefono;
    correo = Ncorreo;
    password = Npassword;
    confirpassword = Nconfirpassword;
    imagen64 = Nimagen64;
    nameimagen = Nnameimagen;
    notifyListeners();
  }

void actualizarubicacion(double Nlatidud, double Nlogitud) {
    latidud = Nlatidud;
    longitud = Nlogitud;
    notifyListeners();
  }




  // Método para guardar el token en la memoria local
  Future<void> _saveToken(String token, String id) async {
    await _preferencesService.savePreferences(token, true, id);
  }

 Future<void> enviarcuenta(BuildContext context) async {
  final crear = Provider.of<CrearcuentaProvider>(context, listen: false);
  
  if (crear.imagen64!="" && crear.nameimagen!="") {
    cuentaconimg(context);
  } else {
    cuentasinimg(context);
  }
}


  Future<void> cuentaconimg(BuildContext context) async {
    try {
      final crear = Provider.of<CrearcuentaProvider>(context, listen: false);
      final urlImagen = Uri.parse('https://cateringmidd.azurewebsites.net/api/GenerateURLImage/Upload');
      final responseImagen = await http.post(
        urlImagen,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "nombre": crear.imagen64 ?? "",
          "base64": crear.nameimagen ?? "", // Imagen en base64
          
        }),
      );

      if (responseImagen.statusCode == 200) {
        final dataImagen = json.decode(responseImagen.body);
        final imageUrl = dataImagen['imageUrl'];
        crearcuenta(context,imageUrl);
        
      } else {
        throw Exception('Error al subir la imagen');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> crearcuenta(BuildContext context,String url) async {
    try {
      final crear = Provider.of<CrearcuentaProvider>(context, listen: false);
      
      print(url);

        // 2. Crear el cliente
        final urlCliente = Uri.parse('https://cateringmidd.azurewebsites.net/api/Cliente');
        final responseCliente = await http.post(
          urlCliente,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "email": crear.correo ?? "",
            "password": crear.password ?? "",
            "nombre": crear.nombre ?? "",
            "apellido": crear.apellido ?? "",
            "telefono": crear.telefono ?? "",
            "latitud": crear.latidud,
            "longitud": crear.longitud,
            "link_imagen": url,
          }),
        );
        if (responseCliente.statusCode == 201) {
          final dataCliente = json.decode(responseCliente.body);
          final idCliente = dataCliente['id_cliente'];
          _generatetoken(context, idCliente);
          
        } else {
          throw Exception('Error al crear el cliente');
        }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
    Future<void> _generatetoken(BuildContext context, String idCliente) async {
    final urlToken = Uri.parse('https://cateringmidd.azurewebsites.net/api/AuthClient/login/id');
    final responseToken = await http.post(
      urlToken,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "id_cliente": idCliente,
      }),
    );
    if (responseToken.statusCode == 200) {
      final dataToken = json.decode(responseToken.body);
      final token = dataToken['token'];
      await _saveToken(token, idCliente);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      throw Exception('Error al generar el token');
    }
}

Future<void> cuentasinimg(BuildContext context) async {
   
      final crear = Provider.of<CrearcuentaProvider>(context, listen: false);

        final urlCliente = Uri.parse('https://cateringmidd.azurewebsites.net/api/Cliente');
        final responseCliente = await http.post(
          urlCliente,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "email": crear.correo ?? "",
            "password": crear.password ?? "",
            "nombre": crear.nombre ?? "",
            "apellido": crear.apellido ?? "",
            "telefono": crear.telefono ?? "",
            "latitud": crear.latidud,
            "longitud": crear.longitud,
            "link_imagen": "",
          }),
        );
        if (responseCliente.statusCode == 201) {
          final dataCliente = json.decode(responseCliente.body);
          final idCliente = dataCliente['id_cliente'];
          _generatetoken1(context, idCliente);
          
        } else {
          throw Exception('Error al crear el cliente');
        }

  }
    Future<void> _generatetoken1(BuildContext context, String idCliente) async {
    final urlToken = Uri.parse('https://cateringmidd.azurewebsites.net/api/AuthClient/login/id');
    final responseToken = await http.post(
      urlToken,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "id_cliente": idCliente,
      }),
    );
    if (responseToken.statusCode == 200) {
      final dataToken = json.decode(responseToken.body);
      final token = dataToken['token'];
      await _saveToken(token, idCliente);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      throw Exception('Error al generar el token');
    }
}


}