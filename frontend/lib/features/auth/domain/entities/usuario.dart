enum RolUsuario {
  administrador,
  cajera;

  static RolUsuario fromBackend(String valor) {
    switch (valor) {
      case 'ADMINISTRADOR':
        return RolUsuario.administrador;
      case 'CAJERA':
        return RolUsuario.cajera;
      default:
        throw ArgumentError('Rol desconocido: $valor');
    }
  }
}

class Usuario {
  final int id;
  final String email;
  final String nombreCompleto;
  final RolUsuario rol;

  const Usuario({
    required this.id,
    required this.email,
    required this.nombreCompleto,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      email: json['email'] as String,
      nombreCompleto: json['nombreCompleto'] as String,
      rol: RolUsuario.fromBackend(json['rol'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombreCompleto': nombreCompleto,
    'rol': rol == RolUsuario.administrador ? 'ADMINISTRADOR' : 'CAJERA',
  };
}

/// A row in the admin's user management list (GET /users). Separate from
/// [Usuario] because it carries `activo`, which the logged-in session's
/// own identity doesn't need.
class UsuarioResumen {
  final int id;
  final String email;
  final String nombreCompleto;
  final RolUsuario rol;
  final bool activo;

  const UsuarioResumen({
    required this.id,
    required this.email,
    required this.nombreCompleto,
    required this.rol,
    required this.activo,
  });

  factory UsuarioResumen.fromJson(Map<String, dynamic> json) {
    return UsuarioResumen(
      id: json['id'] as int,
      email: json['email'] as String,
      nombreCompleto: json['nombreCompleto'] as String,
      rol: RolUsuario.fromBackend(json['rol'] as String),
      activo: json['activo'] as bool,
    );
  }
}
