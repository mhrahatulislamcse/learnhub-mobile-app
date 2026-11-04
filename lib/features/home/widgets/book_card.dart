import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/book_cover_widget.dart';
import '../../../models/book_model.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Reusable Book Card displaying cover art, title, author, year, and favorite state
/// styled according to Figma Screen 03 & 05
class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final Widget? trailing;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(book.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Figma Book Cover Widget (Pastel vector or image)
              BookCoverWidget(
                title: book.title,
                coverUrl: book.coverUrl,
                width: 70,
                height: 98,
                borderRadius: 9,
              ),
              const SizedBox(width: 14),

              // Book Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authorDisplay,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (book.firstPublishYear != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.pillBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.firstPublishYear!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.pillBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.language ?? 'EN',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing action or favorite indicator
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else if (isFav) ...[
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.heartPink,
                    size: 22,
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
