class User {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String carrera;
  final String codigoEstudiante;

  User({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.carrera,
    required this.codigoEstudiante,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nombre: json['nombres'] ?? json['nombre'] ?? '',
      apellido: json['apellidos'] ?? json['apellido'] ?? '',
      email: json['correo'] ?? json['email'] ?? '',
      carrera: json['carrera'] ?? 'TICS',
      codigoEstudiante: json['cu'] ?? json['codigo_estudiante'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombre,
      'apellidos': apellido,
      'correo': email,
      'carrera': carrera,
      'cu': codigoEstudiante,
    };
  }

  String get fullName => '$nombre $apellido';
}
