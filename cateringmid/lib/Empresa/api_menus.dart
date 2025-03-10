import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Menus {
  String idMenuEmpresa;
  String idEmpresa;
  String nombre;
  String descripcion;
  String linkImagen;
  double precio;
  int minPersonas;
  int maxPersonas;

  Menus({
    required this.idMenuEmpresa,
    required this.idEmpresa,
    required this.nombre,
    required this.descripcion,
    required this.linkImagen,
    required this.precio,
    required this.minPersonas,
    required this.maxPersonas,
  });

  // Convertir JSON a un objeto Menus
  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      idMenuEmpresa: json['id_menu_empresa'],
      idEmpresa: json['id_empresa'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      linkImagen: json['link_imagen'],
      precio: json['precio'].toDouble(),
      minPersonas: json['min_personas'],
      maxPersonas: json['max_personas'],
    );
  }

  // Convertir un objeto Menus a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_menu_empresa': idMenuEmpresa,
      'id_empresa': idEmpresa,
      'nombre': nombre,
      'descripcion': descripcion,
      'link_imagen': linkImagen,
      'precio': precio,
      'min_personas': minPersonas,
      'max_personas': maxPersonas,
    };
  }

  @override
  String toString() {
    return 'Menu(nombre: $nombre, id_empresa: $idEmpresa, imagen: $linkImagen, precio: $precio)';
  }
}


class Apimenuclass {
  List<Menus> menu = [];  // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> fetchMenusEmpresaData(String id_empresa) async {
  if (isLoading || !hasMore) return;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {

    return;
  }

  final headers = {
    'Authorization': 'Bearer $token',
  };

  try {
    isLoading = true;
    final response = await http.get(
      Uri.parse(
        'https://cateringmidd.azurewebsites.net/api/MenusEmpresa/Empresa/$id_empresa',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body);
    menu.clear();
    menu.addAll(jsonResponse.map((item) => Menus.fromJson(item)).toList());
    } else if (response.statusCode == 401) {

      await _refreshToken(); // Intenta renovar el token
     
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  } catch (e) {

  } finally {
    isLoading = false;
  }
}


Future<void> _refreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('refresh_token'); // Almacena el refresh token

  if (refreshToken == null) {

    return;
  }

  final response = await http.post(
    Uri.parse('https://cateringmidd.azurewebsites.net/api/auth/refresh'),
    body: {'refresh_token': refreshToken},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final newToken = data['access_token'];

    await prefs.setString('token', newToken);

  } else {

  }
}


 
 

}


