import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/auth/domain/entities/usuario.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';
import 'package:modelo_sqlite/features/auth/presentation/widgets/cambiar_password_dialog.dart';

class RegistrarUsuarioScreen extends ConsumerStatefulWidget {
  const RegistrarUsuarioScreen({super.key});

  @override
  ConsumerState<RegistrarUsuarioScreen> createState() =>
      _RegistrarUsuarioScreenState();
}

class _RegistrarUsuarioScreenState
    extends ConsumerState<RegistrarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  RolUsuario _rolSeleccionado = RolUsuario.cajera;
  bool _guardando = false;
  bool _mostrarPassword = false;

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .crearUsuario(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            nombreCompleto: _nombreController.text.trim(),
            rol: _rolSeleccionado,
          );
      if (!mounted) return;
      _nombreController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() => _rolSeleccionado = RolUsuario.cajera);
      ref.invalidate(listaUsuariosProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el usuario: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _editarUsuario(UsuarioResumen usuario) async {
    final nombreController = TextEditingController(
      text: usuario.nombreCompleto,
    );
    final emailController = TextEditingController(text: usuario.email);
    RolUsuario rolSeleccionado = usuario.rol;
    final formKey = GlobalKey<FormState>();
    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Editar usuario'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Ingresa un nombre'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Ingresa un email'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<RolUsuario>(
                      value: rolSeleccionado,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(
                          value: RolUsuario.cajera,
                          child: Text('Cajera'),
                        ),
                        DropdownMenuItem(
                          value: RolUsuario.administrador,
                          child: Text('Administrador'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(
                          () => rolSeleccionado = value ?? RolUsuario.cajera,
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => guardando = true);
                          try {
                            await ref
                                .read(authRepositoryProvider)
                                .actualizarUsuario(
                                  id: usuario.id,
                                  email: emailController.text.trim(),
                                  nombreCompleto: nombreController.text.trim(),
                                  rol: rolSeleccionado,
                                );
                            ref.invalidate(listaUsuariosProvider);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (e) {
                            setDialogState(() => guardando = false);
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('No se pudo guardar: $e')),
                            );
                          }
                        },
                  child: Text(guardando ? 'Guardando...' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cambiarEstado(UsuarioResumen usuario, bool nuevoValor) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .cambiarEstadoUsuario(id: usuario.id, activo: nuevoValor);
      ref.invalidate(listaUsuariosProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaUsuarios = ref.watch(listaUsuariosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresa un nombre'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresa un email'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: !_mostrarPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña temporal',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _mostrarPassword = !_mostrarPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    if (value.length < 4) return 'Mínimo 4 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<RolUsuario>(
                  value: _rolSeleccionado,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(
                      value: RolUsuario.cajera,
                      child: Text('Cajera'),
                    ),
                    DropdownMenuItem(
                      value: RolUsuario.administrador,
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(
                      () => _rolSeleccionado = value ?? RolUsuario.cajera,
                    );
                  },
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _guardando ? null : _crearUsuario,
                  child: Text(_guardando ? 'Creando...' : 'Crear usuario'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Usuarios existentes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...listaUsuarios.when(
            loading: () => [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (e, _) => [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No se pudo cargar la lista: $e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
            data: (usuarios) => usuarios.map((usuario) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    usuario.nombreCompleto,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${usuario.email} · '
                    '${usuario.rol == RolUsuario.administrador ? 'Administrador' : 'Cajera'}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit, color: Colors.greenAccent),
                        onPressed: () => _editarUsuario(usuario),
                      ),
                      IconButton(
                        tooltip: 'Restablecer contraseña',
                        icon: const Icon(Icons.lock_reset, color: Colors.orangeAccent),
                        onPressed: () => mostrarDialogoCambiarPassword(
                          context,
                          ref,
                          id: usuario.id,
                          esPropia: false,
                          nombreUsuario: usuario.nombreCompleto,
                        ),
                      ),
                      Switch(
                        value: usuario.activo,
                        onChanged: (nuevoValor) =>
                            _cambiarEstado(usuario, nuevoValor),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
