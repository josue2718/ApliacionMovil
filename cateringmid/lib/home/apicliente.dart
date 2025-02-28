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
  DateTime fechaDeCreacion;

  Cliente({
    required this.idCliente,
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.linkImagen,
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
        'https://cateringmidd.azurewebsites.net/api/Cliente/$id_cliente',
      ),
      headers: headers,
    );

    print('Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {

     final jsonResponse = json.decode(response.body);
      cliente.clear();
      cliente.add(Cliente.fromJson(jsonResponse));

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

}


