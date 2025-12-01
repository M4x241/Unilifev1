class Announcement {
  final int id;
  final String titulo;
  final String contenido;
  final String carrera;
  final String categoria;
  final DateTime? fecha;
  final String? imagenUrl;

  Announcement({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.carrera,
    required this.categoria,
    this.fecha,
    this.imagenUrl,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    // API returns 'anuncio' for the main text and timestamps 'created_at'/'updated_at'.
    final String anuncio = json['anuncio']?.toString() ?? '';
    return Announcement(
      id: json['id'] ?? 0,
      // Use 'titulo' if provided, otherwise fallback to 'anuncio'.
      titulo: json['titulo']?.toString() ?? anuncio,
      // Use 'contenido' if provided, otherwise fallback to 'anuncio'.
      contenido: json['contenido']?.toString() ?? anuncio,
      carrera: json['carrera']?.toString() ?? 'General',
      categoria: json['categoria']?.toString() ?? 'General',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
      imagenUrl: json['imagen_url']?.toString() ?? json['imagenUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'carrera': carrera,
      'categoria': categoria,
      'fecha': fecha?.toIso8601String(),
      'imagen_url': imagenUrl,
    };
  }

  String get formattedDate {
    if (fecha == null) return '';
    final now = DateTime.now();
    final diff = now.difference(fecha!);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Hace ${diff.inMinutes} min';
      }
      return 'Hace ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays}d';
    } else {
      return '${fecha!.day}/${fecha!.month}/${fecha!.year}';
    }
  }
}
