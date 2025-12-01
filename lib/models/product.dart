class Product {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String? imagenUrl;
  final String categoria;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    this.imagenUrl,
    required this.categoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      precio: double.parse(json['precio'].toString()),
      stock: json['cantidad'] ?? 0,
      imagenUrl: json['imagen_url'],
      categoria: json['categoria'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad': stock,
      'imagen_url': imagenUrl,
      'categoria': categoria,
    };
  }

  bool get isAvailable => stock > 0;
}
