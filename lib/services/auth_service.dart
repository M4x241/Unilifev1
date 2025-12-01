import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:unilife/services/api_service.dart';
import 'package:unilife/models/user.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  User? _currentUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiService get apiService => _apiService;

  // Inicializar y verificar si hay una sesión guardada
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Intentar leer el token con un timeout de 2 segundos para evitar bloqueos
      _token = await _storage.read(key: 'auth_token').timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      
      if (_token != null) {
        _apiService.setToken(_token);
        // Intentar obtener el usuario con timeout
        _currentUser = await _apiService.getMe().timeout(
          const Duration(seconds: 5),
        );
        _isAuthenticated = true;
      }
    } catch (e) {
      // Si hay error o timeout, limpiar la sesión
      print('Error en inicialización: $e');
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
        },
      );
      
      // Verificar que la respuesta tenga el token
      if (response['access_token'] == null) {
        throw Exception('No se recibió token de autenticación');
      }
      
      _token = response['access_token'] as String;
      await _storage.write(key: 'auth_token', value: _token);
      
      _apiService.setToken(_token);
      
      // Verificar si viene el usuario en la respuesta
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
      } else if (response['universitario'] != null) {
        _currentUser = User.fromJson(response['universitario']);
      } else {
        // Si no viene el usuario, intentar obtenerlo con el token
        try {
          _currentUser = await _apiService.getMe();
        } catch (e) {
          // Si falla, crear un usuario básico con el email
          _currentUser = User(
            id: 0,
            nombre: email.split('@')[0],
            apellido: '',
            email: email,
            carrera: 'TICS',
            codigoEstudiante: '',
          );
        }
      }
      
      _isAuthenticated = true;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignorar errores
    }

    await _storage.delete(key: 'auth_token');
    _token = null;
    _currentUser = null;
    _isAuthenticated = false;
    _apiService.setToken(null);
    notifyListeners();
  }

  // Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
