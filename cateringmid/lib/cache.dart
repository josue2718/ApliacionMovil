import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Variables de almacenamiento
  static const String _tokenKey = 'token';
  static const String _inicioKey = 'inicio';
  static const String _idKey = 'id';
   static const String _nombre = 'nombre';
    static const String _imagen = 'imagen';

  // Cargar los valores desde SharedPreferences
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    bool? inicio = prefs.getBool(_inicioKey);
    String? id = prefs.getString(_idKey);
    String? nombre = prefs.getString(_nombre);
    String? imagen = prefs.getString(_imagen);

    return {
      'token': token,
      'inicio': inicio,
      'id': id,
      'nombre': nombre,
      'imagen' : imagen,
    };
  }

  // Guardar los valores en SharedPreferences
  Future<void> savePreferences(String token, bool inicio, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_inicioKey, inicio);
    await prefs.setString(_idKey, id);

    print(id);
    print(token);
    print(inicio);
  }

   Future<void> saveusuario(String nombre, String imagen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nombre, nombre);
    await prefs.setString(_imagen, imagen);

    print(nombre);
    print(imagen);
  }

  // Eliminar todos los datos de SharedPreferences (opcional)
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_inicioKey);
    await prefs.remove(_idKey);
    await prefs.remove(_nombre);
    await prefs.remove(_imagen);
  }
}
