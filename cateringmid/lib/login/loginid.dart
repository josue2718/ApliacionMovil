import 'dart:convert';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache.dart';
import '../home/home.dart';

class Logincuenta {
  final PreferencesService _preferencesService = PreferencesService(); // Instancia del servicio
   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _saveToken(String token, String id) async {
    await _preferencesService.savePreferences(token, "true", id);
  }

   Future<void> getFCMToken() async {
    // Solicita permisos para recibir notificaciones
    await _firebaseMessaging.requestPermission();

    // Obtiene el token FCM para el dispositivo
    _firebaseMessaging.getToken().then((token) {
      if (token != null) {
        print("Token FCM: $token");
      }
    });
    
   }

  Future<void> login(BuildContext context) async {
    String tokenfcm = await _firebaseMessaging.getToken() ?? '';
    print(tokenfcm);
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    final urlToken = Uri.parse(
        'https://cateringmid.azurewebsites.net/api/AuthClient/login/id');
    final responseToken = await http.post(
      urlToken,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "id_cliente": id,
      }),
    );
    if (responseToken.statusCode == 200) {
         final dataToken = json.decode(responseToken.body);
      final urlLogin = Uri.parse(
          'https://cateringmid.azurewebsites.net/api/Cliente/token/${dataToken['idCliente']}');
      final responseLogin = await http.put(
        urlLogin,
        headers: {
          'Content-Type': 'application/json',
           'Authorization': 'Bearer ${dataToken['token']}',
        },
        body: json.encode({
          "id_cliente": dataToken['idCliente'],
          "email": "string", // Cambia por los valores reales
          "password": "string", // Cambia por los valores reales
          "nombre": "string", // Cambia por los valores reales
          "apellido": "string", // Cambia por los valores reales
          "telefono": "string", // Cambia por los valores reales
          "link_imagen": "string", // Cambia por los valores reales
          "tokenfcm": tokenfcm, // Incluye el token FCM
  "fecha_de_creacion": "2025-03-23T03:17:14.262Z"
        }),
      );
      print(responseLogin.body);
      if (responseLogin.statusCode == 204) {
     
        final token = dataToken['token'];
        final id = dataToken['idCliente'];
        await _saveToken(token, id);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }
}
