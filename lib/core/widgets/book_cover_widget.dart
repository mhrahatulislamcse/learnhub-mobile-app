import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Renders a book cover matching the Figma UI vector style
/// (pastel background, open book silhouette, title badge, and network image fallback).
class BookCoverWidget extends StatelessWidget {
  final String title;
  final String? coverUrl;
  final double width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const BookCoverWidget({
    super.key,
    required this.title,
    this.coverUrl,
    this.width = 96,
    this.height = 120,
    this.borderRadius = 9,
    this.backgroundColor,
    this.textColor,
  });

  // Deterministically pick a pastel palette based on title hash
  (Color bg, Color text) _getPalette() {
    if (backgroundColor != null && textColor != null) {
      return (backgroundColor!, textColor!);
    }
    final hash = title.hashCode.abs();
    final palettes = [
      (AppColors.coverBlue, AppColors.coverBlueText),
      (AppColors.coverPeach, AppColors.coverPeachText),
      (AppColors.coverMint, AppColors.coverMintText),
      (AppColors.coverPurple, AppColors.coverPurpleText),
      (AppColors.coverPink, AppColors.coverPinkText),
    ];
    return palettes[hash % palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final palette = _getPalette();
    final effectiveBg = backgroundColor ?? palette.$1;
    final effectiveText = textColor ?? palette.$2;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: coverUrl != null && coverUrl!.isNotEmpty
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFigmaCover(effectiveBg, effectiveText),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildFigmaCover(effectiveBg, effectiveText);
                },
              )
            : _buildFigmaCover(effectiveBg, effectiveText),
      ),
    );
  }

  Widget _buildFigmaCover(Color bg, Color textColor) {
    final words = title.trim().split(RegExp(r'\s+'));
    final line1 = words.isNotEmpty ? words.take(2).join(' ').toUpperCase() : 'LEARN';
    final line2 = words.length > 2 ? words.skip(2).take(2).join(' ').toUpperCase() : '';

    return Stack(
      children: [
        // Subtle book pages silhouette
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(width * 0.1),
            child: CustomPaint(
              painter: _BookPagePainter(color: textColor.withValues(alpha: 0.12)),
            ),
          ),
        ),

        // Typography inside cover
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line1,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: (width * 0.12).clamp(9.0, 18.0),
                    letterSpacing: 0.8,
                  ),
                ),
                if (line2.isNotEmpty) ...[
                  SizedBox(height: height * 0.03),
                  Text(
                    line2,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: (width * 0.085).clamp(7.0, 13.0),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                SizedBox(height: height * 0.04),
                Container(
                  width: width * 0.45,
                  height: 1.2,
                  color: textColor.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookPagePainter extends CustomPainter {
  final Color color;

  _BookPagePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Open book page curve
    path.moveTo(0, size.height * 0.08);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.08);
    path.lineTo(size.width, size.height * 0.92);
    path.quadraticBezierTo(size.width * 0.5, size.height, 0, size.height * 0.92);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BookPagePainter oldDelegate) => oldDelegate.color != color;
}

