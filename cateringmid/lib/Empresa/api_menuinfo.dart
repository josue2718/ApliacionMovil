import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Gastronomia {
  String idGastronomia;
  String idMenuEmpresa;
  int idTipoGastronomia;
  String nombre;
  double costo;
  String descripcion;
  String linkImagen;

  Gastronomia({
    required this.idGastronomia,
    required this.idMenuEmpresa,
    required this.idTipoGastronomia,
    required this.nombre,
    required this.costo,
    required this.descripcion,
    required this.linkImagen,
  });

  factory Gastronomia.fromJson(Map<String, dynamic> json) {
    return Gastronomia(
      idGastronomia: json['id_gastronomia'],
      idMenuEmpresa: json['id_menu_empresa'],
      idTipoGastronomia: json['id_tipo_gastronomia'],
      nombre: json['nombre'],
      costo: json['costo'],
      descripcion: json['descripcion'],
      linkImagen: json['link_imagen'],
    );
  }
  @override
  String toString() {
    return 'gastronomia(nombre: $nombre, costo: $costo, imagen: $linkImagen';
  }
}

class Menusinfo {
  String idMenuEmpresa;
  String idEmpresa;
  String nombre;
  String descripcion;
  String linkImagen;
  double precio;
  bool mobiliario;
  bool blancos;
  bool personal;
  bool cristaleria;
  bool chef;
  bool meseros;
  int minPersonas;
  int maxPersonas;

  Menusinfo({
    required this.idMenuEmpresa,
    required this.idEmpresa,
    required this.nombre,
    required this.descripcion,
    required this.linkImagen,
    required this.precio,
    required this.mobiliario,
    required this.blancos,
    required this.personal,
    required this.cristaleria,
    required this.chef,
    required this.meseros,
    required this.minPersonas,
    required this.maxPersonas,
  });

  // Convertir JSON a un objeto Menus
  factory Menusinfo.fromJson(Map<String, dynamic> json) {
    return Menusinfo(
      idMenuEmpresa: json['id_menu_empresa'],
      idEmpresa: json['id_empresa'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      linkImagen: json['link_imagen'],
      precio: json['precio'].toDouble(),
      mobiliario: json['mobiliario'],
      blancos: json['blancos'],
      personal: json['personal'],
      cristaleria: json['cristaleria'],
      chef: json['chef'],
      meseros: json['meseros'],
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
      'mobiliario': mobiliario,
      'blancos': blancos,
      'personal': personal,
      'cristaleria': cristaleria,
      'chef': chef,
      'meseros': meseros,
      'min_personas': minPersonas,
      'max_personas': maxPersonas,
    };
  }

  @override
  String toString() {
    return 'Menu(nombre: $nombre, id_empresa: $idEmpresa, imagen: $linkImagen, precio: $precio)';
  }
}


class Apimenuinfoclass {
  List<Menusinfo> menuinfo = [];  // Lista de empresas
  List<Gastronomia> gastronomia =[]; 
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> fetchMenuinfoData(String id_menu_empresa) async {
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
        'https://cateringmidd.azurewebsites.net/api/MenusEmpresa/$id_menu_empresa',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {

     final jsonResponse = json.decode(response.body);
      menuinfo.clear();
      gastronomia.clear();
      menuinfo.add(Menusinfo.fromJson(jsonResponse));
      final List<dynamic> data = jsonResponse['gastronomias'] ?? [];
        gastronomia .addAll(data.map((item) => Gastronomia.fromJson(item)).toList());
    } else if (response.statusCode == 401) {

    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  } catch (e) {

  } finally {
    isLoading = false;
  }
}

}


