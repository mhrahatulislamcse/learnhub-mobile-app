import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

/// Reusable error widget with an icon, message, and retry button
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Try Again',
                width: 160,
                backgroundColor: AppColors.secondary,
                textColor: Colors.white,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
