import 'package:flutter/material.dart';

/// Filtre catégorie (Caisse, Catalogue) — libellé coloré à la sélection, sans avatar.
class CategoryFilterChip extends StatelessWidget {
  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      showCheckmark: false,
      label: Text(
        label,
        style: TextStyle(
          color: selected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.35)
            : colorScheme.outline.withValues(alpha: 0.22),
      ),
    );
  }
}
