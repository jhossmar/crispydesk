import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modelo_sqlite/features/auth/presentation/providers/auth_providers.dart';

/// Shows the change-password dialog. When [esPropia] is true, the user is
/// changing their own password and must provide the current one (verified
/// by the backend). When false, an Administrador is resetting someone
/// else's password and no current password is needed.
Future<void> mostrarDialogoCambiarPassword(
  BuildContext context,
  WidgetRef ref, {
  required int id,
  required bool esPropia,
  String? nombreUsuario,
}) {
  final actualController = TextEditingController();
  final nuevaController = TextEditingController();
  final confirmarController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool guardando = false;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(
              esPropia
                  ? 'Cambiar contraseña'
                  : 'Restablecer contraseña de $nombreUsuario',
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (esPropia) ...[
                    TextFormField(
                      controller: actualController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña actual',
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Ingresa tu contraseña actual'
                          : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: nuevaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña nueva',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa una contraseña nueva';
                      }
                      if (value.length < 4) return 'Mínimo 4 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirmarController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña nueva',
                    ),
                    validator: (value) => value != nuevaController.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: guardando ? null : () => Navigator.pop(dialogContext),
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
                              .cambiarPassword(
                                id: id,
                                passwordActual: esPropia
                                    ? actualController.text
                                    : null,
                                passwordNueva: nuevaController.text,
                              );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contraseña actualizada correctamente'),
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => guardando = false);
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('No se pudo cambiar: $e')),
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
