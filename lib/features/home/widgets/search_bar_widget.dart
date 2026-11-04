import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Clean Search Bar matching Figma Screen 03 (393 x 852 px design)
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSubmitted;
  final VoidCallback onClear;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    this.hintText = 'Search books, authors, topics',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.lightBorder, width: 1),
        ),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 14, color: AppColors.lightTextPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.placeholder,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.lightTextSecondary,
              size: 22,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.lightTextSecondary),
                    onPressed: onClear,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
