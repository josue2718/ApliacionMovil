import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class EmpresasSearch {
  String nombre;
  String link_logo;
  String id_empresa;



  EmpresasSearch({
    required this.nombre,
    required this.link_logo,
    required this.id_empresa,

  });

  factory EmpresasSearch.fromJson(Map<String, dynamic> json) {
    return EmpresasSearch(
      nombre: json['nombre'],
      link_logo: json['link_logo'],
      id_empresa: json['id_empresa'],
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $nombre, id_empresa: $id_empresa)';
  }
}

class ApiclassSearch {
  List<EmpresasSearch> empresassearch = []; // Lista de empresas

  bool isLoading = false;
  bool hasMore = true;



  Future<void> fetchEmpresaData() async {
    if (isLoading || !hasMore) return;
print('no');
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
          'https://cateringmidd.azurewebsites.net/api/Empresa/Search',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        empresassearch.clear();
        empresassearch.addAll(jsonResponse.map((item) => EmpresasSearch.fromJson(item)).toList());
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
  