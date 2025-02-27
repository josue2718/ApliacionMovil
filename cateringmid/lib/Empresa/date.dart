import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Date 
{
  String fecha;

  Date({
    required this.fecha
  });

  factory Date.fromJson(Map<String, dynamic> json) {
    return Date(
      fecha: json['fecha']
    );
  }

   @override
  String toString() {
    return 'Date(tipo: $fecha)';
  }
}


class Apidateempresaclass {

  List <Date> date =[];
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> fetchEmpresaIDData(String id_empresa) async {
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
        'https://cateringmidd.azurewebsites.net/api/Reservas/date/${id_empresa}',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      
        final List<dynamic> jsonResponse = json.decode(response.body);
        date.clear();
        date.addAll( jsonResponse.map((item) => Date.fromJson(item)).toList());


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


