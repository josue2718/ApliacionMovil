import 'package:cateringmid/cache.dart';
import 'package:cateringmid/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Cliente {
  String idCliente;
  String email;
  String password;
  String nombre;
  String apellido;
  String telefono;
  String linkImagen;
  String tokenfcm;
  DateTime fechaDeCreacion;

  Cliente({
    required this.idCliente,
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.linkImagen,
    required this.tokenfcm,
    required this.fechaDeCreacion,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'],
      email: json['email'],
      password: json['password'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      linkImagen: json['link_imagen'],
      tokenfcm:json['tokenfcm'],
      fechaDeCreacion: DateTime.parse(json['fecha_de_creacion']),
    );
  }

  @override
  String toString() {
    return 'Cliente(nombre: $nombre, apellido: $apellido, email: $email)';
  }
}



class Apiclienteclass {
  List<Cliente> cliente = [];  // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;
  final PreferencesService _preferencesService = PreferencesService(); // Instancia del servicio
   Future<void> _saveuser(String nombre,String imagen) async {
    await _preferencesService.saveusuario(nombre,imagen);
  }

  Future<void> fetchclienteData() async {
  print("llamado");
  if (isLoading || !hasMore) return;
  final prefs = await SharedPreferences.getInstance();
  final id_cliente = prefs.getString('id');
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    print('El token no está configurado o es inválido');
    return;
  }

  final headers = {
    'Authorization': 'Bearer $token',
  };

  try {
    isLoading = true;
    final response = await http.get(
      Uri.parse(
        'https://cateringmid.azurewebsites.net/api/Cliente/$id_cliente',
      ),
      headers: headers,
    );

    //hola

    print('Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {

     final data = json.decode(response.body);
       await _saveuser(data['nombre'], data['link_imagen']);

    } else if (response.statusCode == 401) {
      print('Token expirado, intentando renovar...');
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al obtener datos: $e');
  } finally {
    isLoading = false;
  }
}


  Future<void> fetchlcerrarData(BuildContext context) async {
    print("Llamado");
    if (isLoading || !hasMore) return; // Evita llamadas si ya está cargando o no hay más datos.

    final prefs = await SharedPreferences.getInstance();
    final id_cliente = prefs.getString('id');
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('El token no está configurado o es inválido');
      return;
    }

    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      isLoading = true; // Marcar como cargando para evitar solicitudes múltiples.

      // URL correcta con el id_cliente
      final urlLogin = Uri.parse(
          'https://cateringmid.azurewebsites.net/api/Cliente/token/$id_cliente');

      // Realizamos una solicitud PUT con los datos correspondientes
      final responseLogin = await http.put(
        urlLogin,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "id_cliente": id_cliente,
          "email": "string", // Cambiar por datos reales
          "password": "string", // Cambiar por datos reales
          "nombre": "string", // Cambiar por datos reales
          "apellido": "string", // Cambiar por datos reales
          "telefono": "string", // Cambiar por datos reales
          "link_imagen": "string", // Cambiar por datos reales
          "tokenfcm": "tokenfcm", // Asegúrate de obtener el token FCM correctamente
          "fecha_de_creacion": DateTime.now().toIso8601String() // Usa la fecha actual en formato ISO
        }),
      );

      // Comprobamos la respuesta del servidor
      if (responseLogin.statusCode == 204) {

        final PreferencesService _preferencesService = PreferencesService();
    _preferencesService.clearPreferences();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) =>  SplashScreen()),
      (route) => false,
    );
      } else {
        // Muestra un mensaje de error si las credenciales son incorrectas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error'), backgroundColor: Color(0xFF670A0A)),
        );
      }
    } catch (e) {
      print('Error al obtener datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener datos'), backgroundColor: Color(0xFF670A0A)),
      );
    } finally {
      isLoading = false; // Marcar como no cargando al finalizar
    }
  }
}


