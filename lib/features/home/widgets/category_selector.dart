import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Horizontal scrollable category filter bar matching Figma Screen 03 (Explore categories)
class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final void Function(String) onSelectCategory;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;

          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            selectedColor: AppColors.secondary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected ? AppColors.secondary : AppColors.lightBorder,
                width: 1,
              ),
            ),
            showCheckmark: false,
            onSelected: (_) => onSelectCategory(cat),
          );
        },
      ),
    );
  }
}
