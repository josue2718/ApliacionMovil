import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment() async {
    try {
      String paymentIntentClientSecret = await createPaymentIntent(1000, "mxn");
      if (paymentIntentClientSecret == null) return;

      // Inicializar el PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "pago"
        ),
      );
      await _processPayment();

      // Mostrar el PaymentSheet
      await Stripe.instance.presentPaymentSheet();

    } catch (e) {
      print(e);
    }
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentCustomerSheet();
    } catch (e) {
      print(e);
    }
  }

  Future<String> createPaymentIntent(int amount, String currency) async {
    final response = await http.post(
      Uri.parse('https://cateringmidd.azurewebsites.net/api/Payment/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': amount,
        'currency': currency,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);  
      // Asegurarse de que clientSecret no sea nulo
      if (data['clientSecret'] != null) {
        return data['clientSecret']; // Extraer el clientSecret
      } else {
        throw Exception('ClientSecret es nulo');
      }
    } else {
      throw Exception('Error al crear PaymentIntent');
    }
  }
}
