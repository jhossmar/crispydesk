import 'package:flutter/material.dart';

/// Icon/color per product category, shared across the product list, the
/// sales grid, and the quantity screen so a new category only needs to be
/// added here once.
extension CategoriaVisual on String {
  IconData get iconoCategoria => switch (this) {
    'Pollo' => Icons.set_meal,
    'Bebida' => Icons.local_drink,
    'Acompañamiento' => Icons.rice_bowl,
    _ => Icons.fastfood,
  };

  Color get colorCategoria => switch (this) {
    'Pollo' => Colors.orangeAccent.shade200,
    'Bebida' => Colors.blueAccent.shade200,
    'Acompañamiento' => Colors.greenAccent.shade200,
    _ => Colors.grey.shade400,
  };
}
