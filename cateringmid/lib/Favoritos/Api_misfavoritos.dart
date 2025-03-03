import 'package:cateringmid/Favoritos/misfavoritos.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Misfavoritos {
  String id_empresa;
  String empresanombre;
  String empresalogo;
  String idfavorito;

  Misfavoritos({
    required this.id_empresa,
    required this.empresanombre,
    required this.empresalogo,
    required this.idfavorito,
  });

  // Convertir JSON a un objeto Menus
  factory Misfavoritos.fromJson(Map<String, dynamic> json) {
    return Misfavoritos(
        id_empresa: json['id_empresa'],
        empresalogo: json['empresalogo'],
        empresanombre: json['empresaNombre'],
        idfavorito: json['id_favorito']);
  }

  // Convertir un objeto Menus a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_empresa': id_empresa,
      'empresaNombre': empresanombre,
      'empresalogo': empresalogo,
      'id_favorito': idfavorito
    };
  }

  @override
  String toString() {
    return 'Menu(nombre: $empresanombre, id_empresa: $id_empresa)';
  }
}

class Apimisfavoritos {
  //List<Menusinfo> menuinfo = [];  // Lista de empresas
  List<Misfavoritos> misfavoritos = [];
  bool isLoading = false;
  bool hasMore = true;

  var inforeservas;

  Future<void> fetchfavoritos() async {
    if (isLoading || !hasMore) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id_cliente = prefs.getString('id');
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
          'https://cateringmidd.azurewebsites.net/api/Favorito/Cliente/$id_cliente',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        misfavoritos.clear();
        misfavoritos.addAll(
            jsonResponse.map((item) => Misfavoritos.fromJson(item)).toList());
      } else if (response.statusCode == 401) {
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }

  Future<void> deletefavoritos( {required String id, required BuildContext context}) async {
    if (isLoading || !hasMore) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id_cliente = prefs.getString('id');
    if (token == null || token.isEmpty) {
      return;
    }

    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      isLoading = true;
      final response = await http.delete(
        Uri.parse(
          'https://cateringmidd.azurewebsites.net/api/Favorito/$id',
        ),
        headers: headers,
      );
        print(response.statusCode);
      if (response.statusCode == 204) {
       ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
          content: Text('empresa eliminada de favoritos'),
          backgroundColor: Color(0xFF670A0A),
          duration: const Duration(seconds: 1),           
        ),
        
      ); 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>Misfavoritospage()),
      );
      } else if (response.statusCode == 401) {
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
          content: Text('No se pudo eliminar'),
          backgroundColor: Color(0xFF670A0A),
          duration: const Duration(seconds: 1),           
        ),
      );
        
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }
}
