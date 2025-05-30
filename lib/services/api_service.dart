import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';
import '../models/transaction.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  /// Obtener la cuenta principal
  static Future<Account> getAccount() async {
    final response = await http.get(Uri.parse("$baseUrl/api/account"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // Validación para evitar errores si falta el campo
      if (json != null && json['balance'] != null) {
        return Account.fromJson(json);
      } else {
        throw Exception("El campo 'balance' no existe en la respuesta.");
      }
    } else {
      throw Exception("Error al obtener la cuenta: ${response.statusCode}");
    }
  }

  /// Obtener las transacciones recientes
  static Future<List<Transaction>> getRecentTransactions() async {
    final response = await http.get(Uri.parse("$baseUrl/api/account/transactions"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener transacciones: ${response.statusCode}");
    }
  }

  /// Refrescar la cuenta (p. ej. para actualizar saldo)
  static Future<void> refreshAccount() async {
    final response = await http.post(Uri.parse("$baseUrl/api/account/refresh"));

    if (response.statusCode != 200) {
      throw Exception("Error al refrescar el saldo: ${response.statusCode}");
    }
  }

  /// Cerrar sesión del usuario
  static Future<void> logout() async {
    final response = await http.post(Uri.parse("$baseUrl/api/auth/logout"));

    if (response.statusCode != 200) {
      throw Exception("Error al cerrar sesión: ${response.statusCode}");
    }
  }
}
