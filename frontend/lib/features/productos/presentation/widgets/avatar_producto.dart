import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:modelo_sqlite/features/productos/domain/entities/producto.dart';
import 'package:modelo_sqlite/features/productos/presentation/widgets/categoria_visual.dart';

/// Decodes a product's `imagen` (a `data:<mime>;base64,<data>` string) into
/// raw bytes, or null if there's no image or it's malformed.
Uint8List? decodificarImagenProducto(String? imagen) {
  if (imagen == null) return null;
  final indice = imagen.indexOf('base64,');
  if (indice == -1) return null;
  try {
    return base64Decode(imagen.substring(indice + 7));
  } catch (_) {
    return null;
  }
}

/// A CircleAvatar showing the product's photo when it has one, falling
/// back to the category icon/color (see categoria_visual.dart) otherwise.
class AvatarProducto extends StatelessWidget {
  final Producto producto;
  final double radius;
  final double? iconSize;

  const AvatarProducto({
    super.key,
    required this.producto,
    this.radius = 24,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = decodificarImagenProducto(producto.imagen);
    if (bytes != null) {
      return CircleAvatar(radius: radius, backgroundImage: MemoryImage(bytes));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: producto.categoria.colorCategoria,
      child: Icon(
        producto.categoria.iconoCategoria,
        color: Colors.black,
        size: iconSize,
      ),
    );
  }
}
