class Announcement {
  final int id;
  final String titulo;
  final String contenido;
  final String carrera;
  final String categoria;
  final DateTime? fecha;
  final DateTime? fechaInicio;
  final DateTime? fechaFinalizacion;
  final String? detalles;
  final String? imagenUrl;

  Announcement({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.carrera,
    required this.categoria,
    this.fecha,
    this.imagenUrl,
    this.detalles,
    this.fechaInicio,
    this.fechaFinalizacion,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    // API returns 'anuncio' for the main text and timestamps 'created_at'/'updated_at'.
    final String anuncio = json['anuncio']?.toString() ?? '';
    return Announcement(
      id: json['id'] ?? 0,
      // Use 'titulo' if provided, otherwise fallback to 'anuncio'.
      titulo: json['titulo']?.toString() ?? anuncio,
      // Use 'contenido' if provided, otherwise fallback to 'anuncio'.
      contenido: json['detalles']?.toString() ?? anuncio,
      carrera: json['carrera']?.toString() ?? 'General',
      categoria: json['categoria']?.toString() ?? 'General',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null),
      imagenUrl:
          json['imagen_url']?.toString() ?? json['imagenUrl']?.toString(),
      detalles: json['detalles']?.toString(),
      fechaInicio:
          json['fecha_inicio'] != null &&
              json['fecha_inicio'].toString().isNotEmpty
          ? DateTime.parse(json['fecha_inicio'])
          : null,
      fechaFinalizacion:
          json['fecha_finalizacion'] != null &&
              json['fecha_finalizacion'].toString().isNotEmpty
          ? DateTime.parse(json['fecha_finalizacion'])
          : null,
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
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_finalizacion': fechaFinalizacion?.toIso8601String(),
      'detalles': detalles,
      'imagen_url': imagenUrl,
    };
  }

  String get formattedDate {
    // Prefer explicit start date if provided, otherwise fall back to `fecha`.
    final DateTime? start = fechaInicio ?? fecha;
    if (start == null) return '';
    return 'Fecha inicio: ${fechaInicio != null ? '${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}' : ''}';
  }
}
