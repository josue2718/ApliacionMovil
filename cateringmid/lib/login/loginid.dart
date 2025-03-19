import 'dart:convert';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache.dart';
import '../home/home.dart';


class Logincuenta {

 final PreferencesService _preferencesService = PreferencesService(); // Instancia del servicio
  Future<void> _saveToken(String token, String id) async {
    await _preferencesService.savePreferences(token, "true", id);
  }


    Future<void> login(BuildContext context) async {
      final prefs = await SharedPreferences.getInstance();
final id= prefs.getString('id');
    final urlToken = Uri.parse('https://cateringmid.azurewebsites.net/api/AuthClient/login/id');
    final responseToken = await http.post(
      urlToken,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "id_cliente": id,
      }),
    );
    if (responseToken.statusCode == 200) {
      final dataToken = json.decode(responseToken.body);
      final token = dataToken['token'];
       final id = dataToken['idCliente'];
      await _saveToken(token, id);
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
     
     Navigator.pop(context); 
    }

}

     
}


