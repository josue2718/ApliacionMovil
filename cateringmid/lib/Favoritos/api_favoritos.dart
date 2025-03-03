import 'dart:convert';
import 'package:cateringmid/Reservas/reservamenu.dart';
import 'package:cateringmid/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Favoritos {

  Future<void> gardarfavorito({required String empresa, required String nombre, required BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();
    final id_cliente = prefs.getString('id');
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {

    return;
  }

    // Verifica que id_cliente no sea nulo antes de usarlo
    if (id_cliente == null) {

      return; // Evita enviar la solicitud si el id_cliente es nulo
    }

    final url = Uri.parse('https://cateringmidd.azurewebsites.net/api/Favorito');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "id_empresa": empresa,
        "id_cliente": id_cliente
      }),
    );
    print(empresa);
    print(id_cliente);
    print(response.statusCode);
    if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
          content: Text('Se guardo en favorito ${nombre}'),
          backgroundColor: Color(0xFF670A0A),
          duration: const Duration(seconds: 1),           
        ),
      );
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
          content: Text('No se guardo en favorito ${nombre}'),
          backgroundColor: Color(0xFF670A0A),
          duration: const Duration(seconds: 1), 
        ),
      );
    }
  }
}

