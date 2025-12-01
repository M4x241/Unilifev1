import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unilife/models/user.dart';
import 'package:unilife/models/product.dart';
import 'package:unilife/models/marketplace_product.dart';
import 'package:unilife/models/announcement.dart';
import 'package:unilife/models/whatsapp_group.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.100.8:8000/api';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Autenticación
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'correo': email, 'contrasena': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error en login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: _headers);
    } catch (e) {
      // Ignorar errores en logout
    }
  }

  Future<User> getMe() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Error al obtener usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Productos de tienda
  Future<List<Product>> getStoreProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/store/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener productos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Product>> getStoreProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/store/categories/$category/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener productos por categoría');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Productos del marketplace
  Future<List<MarketplaceProduct>> getMarketplaceProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MarketplaceProduct.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener productos del marketplace');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> purchaseMarketplaceProduct(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/marketplace/products/$productId/purchase'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al comprar producto');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Anuncios
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anuncios'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Announcement.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener anuncios');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Announcement>> getAnnouncementsByCarrera(String carrera) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anuncios/carrera/$carrera'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Announcement.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener anuncios por carrera');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Announcement>> getAnnouncementsByCategoria(
    String categoria,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anuncios/categoria/$categoria'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Announcement.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener anuncios por categoría');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Marketplace - Mis Productos
  Future<List<MarketplaceProduct>> getMyProducts(String cu) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Filter products where cu_owner matches current user
        return data
            .map((json) => MarketplaceProduct.fromJson(json))
            .where((product) => product.cuOwner == cu)
            .toList();
      } else {
        throw Exception('Error al obtener mis productos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Marketplace - Mis Compras
  Future<List<MarketplaceProduct>> getMyPurchases(String cu) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Filter products where cu_comprador matches current user
        return data
            .map((json) => MarketplaceProduct.fromJson(json))
            .where((product) => product.cuComprador == cu)
            .toList();
      } else {
        throw Exception('Error al obtener mis compras');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Marketplace - Crear Producto
  Future<MarketplaceProduct> createMarketplaceProduct({
    required String nombre,
    required String descripcion,
    required double precio,
    required String cuOwner,
    String? imagenUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/marketplace/products'),
        headers: _headers,
        body: jsonEncode({
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'cu_owner': cuOwner,
          'imagen_url': imagenUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return MarketplaceProduct.fromJson(data);
      } else {
        throw Exception('Error al crear producto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Marketplace - Actualizar estado de Producto
  Future<MarketplaceProduct> updateMarketplaceProductStatus({
    required int productId,
    required String status,
    String? cuComprador, // Added optional parameter for buyer CU
  }) async {
    try {
      final body = {
        'status': status,
        if (cuComprador != null) 'cu_comprador': cuComprador,
      };

      final response = await http.put(
        Uri.parse(
          '$baseUrl/marketplace/products/$productId',
        ), // Correct endpoint for updating products
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MarketplaceProduct.fromJson(data);
      } else {
        throw Exception(
          'Error al actualizar estado del producto: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Marketplace - Eliminar Producto
  Future<void> deleteMarketplaceProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/marketplace/products/$productId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar producto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // WhatsApp Groups
  Future<List<WhatsAppGroup>> getWhatsAppGroups() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/whatsapp-groups'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WhatsAppGroup.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al obtener grupos de WhatsApp: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
