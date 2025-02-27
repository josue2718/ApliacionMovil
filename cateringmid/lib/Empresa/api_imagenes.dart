import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Imagenes_Empresas {
  String link_imagen;
  Imagenes_Empresas({
    required this.link_imagen,
  });

  factory Imagenes_Empresas.fromJson(Map<String, dynamic> json) {
    return Imagenes_Empresas(
      link_imagen: json['link_imagen'] ?? '', // Asegúrate de manejar valores nulos
    );
  }

  @override
  String toString() {
    return 'Imagen(imagen recolectada:$link_imagen)';
  }
}

class Apiimagenes_Empresasclass {
  List<Imagenes_Empresas> imagenes_Empresas = [];
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> fetchImagenEmpresaData(String id_empresa) async {
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
          'https://cateringmidd.azurewebsites.net/api/Empresa/${id_empresa}',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Limpiar la lista antes de agregar los nuevos datos
        imagenes_Empresas.clear();

        // Obtener las imágenes desde la respuesta
        final List<dynamic> data = jsonResponse['imagenes_Empresas'] ?? [];

        // Filtrar las imágenes no vacías
        final List<Imagenes_Empresas> imagenesFiltradas = data
            .map((item) => Imagenes_Empresas.fromJson(item))
            .where((img) => img.link_imagen.isNotEmpty)
            .toList();

        // Agregar las imágenes filtradas a la lista
        imagenes_Empresas.addAll(imagenesFiltradas);
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