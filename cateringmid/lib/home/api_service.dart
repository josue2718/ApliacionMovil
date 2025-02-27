import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Empresas {
  String nombre;
  String direccion;
  String telefono;
  String link_logo;
  int max_personas;
  int min_personas;
  String id_empresa;
  int premin;
  int estrellas;


  Empresas({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.link_logo,
    required this.max_personas,
    required this.min_personas,
    required this.id_empresa,
    required this.premin,
    required this.estrellas,
  });

  factory Empresas.fromJson(Map<String, dynamic> json) {
    return Empresas(
      nombre: json['nombre'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      link_logo: json['link_logo'],
      max_personas: json['max_personas'],
      min_personas: json['min_personas'],
      id_empresa: json['id_empresa'],
      premin: json['premin'],
      estrellas: json['estrellas']
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $nombre, direccion: $direccion, telefono: $telefono, max_personas: $max_personas, min_personas: $min_personas, id_empresa: $id_empresa)';
  }
}

class Apiclass {
  List<Empresas> empresas = []; // Lista de empresas
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  set loading(bool loading) {}

  Future<void> fetchEmpresaData(int Number) async {
    if (isLoading || !hasMore) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return;
    }

    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse(
          'https://cateringmidd.azurewebsites.net/api/Empresa?pageNumber=$Number&pageSize=10&timestamp=${DateTime.now().millisecondsSinceEpoch}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        empresas.clear();
        empresas.addAll(data.map((item) => Empresas.fromJson(item)).toList());
      } else if (response.statusCode == 401) {

      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {

    } finally {
      isLoading = false;
    }
  }


  Future<void> fetchEmpresatipo(int tipo,int Number) async {
    if (isLoading || !hasMore) return;
 final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      isLoading = true;

      final response = await http.get(
        Uri.parse(
          'https://cateringmidd.azurewebsites.net/api/Empresa/tipo/$tipo?pageNumber=$Number&pageSize=10&timestamp=${DateTime.now().millisecondsSinceEpoch}',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
         final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        empresas.clear();
        empresas.addAll(data.map((item) => Empresas.fromJson(item)).toList());
      } else if (response.statusCode == 401) {
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
    } finally {
      isLoading = false;
  
  

}

  }}