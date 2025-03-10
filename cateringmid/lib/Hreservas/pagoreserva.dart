import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class Apipago {
  String preferenceId = "";

  Future<void> crearPreferencia({required String id_empresa,required String id_cliente,required String id_reserva ,required String empresa ,required double precio }) async {
    final urlCliente =
        Uri.parse('https://cateringmidd.azurewebsites.net/api/pagos/crear-preferencia');
    final responseCliente = await http.post(
      urlCliente,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
       
        "id_cliente": id_cliente,
        "id_empresa":id_empresa,
        "id_reserva": id_reserva,
        "producto": "pago de servicio a ${empresa}",
        "precio": 50,
        "cantidad": 1
      
      }),
    ); print(responseCliente.body);
    if (responseCliente.statusCode == 200) {
      final data = json.decode(responseCliente.body);
     
        preferenceId =  data["value"]["redirect_url"];
        

      String urlPago = "$preferenceId";
      print(urlPago);
      await launch(urlPago, forceSafariVC: false, forceWebView: false);
    } else {
      
    }
  }

 
}
