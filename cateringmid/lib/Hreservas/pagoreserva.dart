import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class Apipago {
  String preferenceId = "";

 Future<void> crearPreferencia(
      {required String id_empresa,
      required String id_cliente,
      required String id_estatus,
      required String id_reserva,
      required String empresa,
      required double precio}) async {
    final urlCliente = Uri.parse(
        'https://cateringmid.azurewebsites.net/api/pagos/crear-preferencia');
    final responseCliente = await http.post(
      urlCliente,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "id_cliente": id_cliente,
        "id_empresa": id_empresa,
        "id_reserva": id_reserva,
        "producto": "pago de servicio a ${empresa}",
        "precio": 50,
        "cantidad": 1
      }),
    );
    print(responseCliente.body);
    if (responseCliente.statusCode == 200) {
      final data = json.decode(responseCliente.body);

      var body = json.encode({
        "id_cliente": id_cliente,
        "id_empresa": id_empresa,
        "id_reserva": id_reserva,
        "producto": "pago de servicio a ${empresa}",
        "precio": 50,
        "cantidad": 1
      });
      crearpago(id_reserva: id_reserva, id_estatus: id_estatus);
      print(data);
      preferenceId = data["value"]["redirect_url"];

      String urlPago = "$preferenceId";
      print(urlPago);
      await launch(urlPago, forceSafariVC: false, forceWebView: false);
    } else {}
  }

  Future<void> crearpago(
      {required String id_reserva, required String id_estatus}) async {
       final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final urlCliente = Uri.parse(
        'https://cateringmid.azurewebsites.net/api/Reservas/Estatus/${id_reserva}');
    final responseCliente = await http.put(
      urlCliente,
      headers: {
        'Content-Type': 'application/json',
         'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "id_reserva": id_reserva,
        "estatus_Reservas": [
          {
            "id_estatus": id_reserva,
            "id_reserva": id_reserva,
            "enviado": true,
            "aceptado": true,
            "pago": true,
            "preparando": false,
            "enviando": false,
            "entregado": false,
            "confirmado": false,
            "completado": false,
            "cancelado": false,
          }
        ],
      }),
    );
    print(responseCliente.statusCode);
    if (responseCliente.statusCode == 200) {
    } else {}
  }

 
}
