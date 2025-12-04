class MarketplaceProduct {
  final int id;
  final String titulo; // product name
  final String descripcion;
  final double precio;
  final String? imagenUrl;
  final String estado;
  // Owner (seller) info
  final String? cuOwner;
  final String? vendedorNombre;
  final String? vendedorWhatsapp;
  // Buyer info (optional)
  final String? cuComprador;
  final String? compradorNombre;
  final DateTime? createdAt;

  MarketplaceProduct({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    this.imagenUrl,
    required this.estado,
    this.cuOwner,
    this.vendedorNombre,
    this.cuComprador,
    this.compradorNombre,
    this.vendedorWhatsapp,
    this.createdAt,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    // Owner name may be composed of nombres and apellidos
    String? ownerName;
    String? ownerWhatsapp;
    if (json['owner'] != null && json['owner'] is Map) {
      final owner = json['owner'] as Map<String, dynamic>;
      final nombres = owner['nombres']?.toString() ?? '';
      final apellidos = owner['apellidos']?.toString() ?? '';
      ownerName = (nombres + ' ' + apellidos).trim();
      ownerWhatsapp = owner['whatsapp']?.toString();
    }
    // Buyer name similar
    String? buyerName;
    if (json['comprador'] != null && json['comprador'] is Map) {
      final buyer = json['comprador'] as Map<String, dynamic>;
      final nombres = buyer['nombres']?.toString() ?? '';
      final apellidos = buyer['apellidos']?.toString() ?? '';
      buyerName = (nombres + ' ' + apellidos).trim();
    }
    return MarketplaceProduct(
      id: json['id'] ?? 0,
      titulo: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precio: double.parse(json['precio']?.toString() ?? '0'),
      imagenUrl: json['imagen_url']?.toString(),
      estado: json['status']?.toString() ?? 'nuevo', // Map 'status' to 'estado'
      cuOwner: json['cu_owner']?.toString(),
      vendedorNombre: ownerName,
      vendedorWhatsapp: ownerWhatsapp,
      cuComprador: json['cu_comprador']?.toString(),
      compradorNombre: buyerName,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'imagen_url': imagenUrl,
      'estado': estado,
      'cu_owner': cuOwner,
      'whatsapp_owner': vendedorWhatsapp,
      'cu_comprador': cuComprador,
      'created_at': createdAt?.toIso8601String(),
      // owner and comprador objects are not reconstructed here
    };
  }

  bool get isNew => estado.toLowerCase() == 'nuevo';
}
