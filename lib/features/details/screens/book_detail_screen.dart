import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/book_cover_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../models/book_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../books/providers/books_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Task 13: Book Detail Screen Source Code (4 points)
/// Replicates Figma Screen 04 (Book details) with Hero animation and Favorites persistence
class BookDetailScreen extends StatelessWidget {
  final BookModel? book;

  const BookDetailScreen({super.key, this.book});

  @override
  Widget build(BuildContext context) {
    final activeBook = book ?? context.watch<BooksProvider>().selectedBook;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (activeBook == null || activeBook.id.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Book details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined, size: 64, color: AppColors.lightTextSecondary),
              const SizedBox(height: 16),
              const Text('No book selected', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final isFav = favoritesProvider.isFavorite(activeBook.id);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Book details',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.heartPink : AppColors.lightTextSecondary,
            ),
            tooltip: isFav ? 'Remove Favorite' : 'Save Favorite',
            onPressed: () async {
              final added = await favoritesProvider.toggleFavorite(
                activeBook,
                userId: authProvider.currentUser?.uid,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(added
                        ? 'Saved "${activeBook.title}" to Favorites'
                        : 'Removed "${activeBook.title}" from Favorites'),
                    backgroundColor: added ? AppColors.success : AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.lightTextSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Book: ${activeBook.title}')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Figma 04: Centered Big Book Cover (161 x 211 px)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Hero(
                  tag: 'book_cover_${activeBook.id}',
                  child: BookCoverWidget(
                    title: activeBook.title,
                    coverUrl: activeBook.coverUrl,
                    width: 161,
                    height: 211,
                    borderRadius: 12,
                    backgroundColor: AppColors.coverBlue,
                    textColor: AppColors.coverBlueText,
                  ),
                ),
              ),
            ),

            // Book Header Info (Figma 04)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    activeBook.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeBook.authorDisplay,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '★ 4.8  ·  Personal growth  ·  240 pages',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Divider Line
            const Divider(color: AppColors.lightBorder, thickness: 1, indent: 24, endIndent: 24),
            const SizedBox(height: 16),

            // About this book (Figma 04)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About this book',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeBook.description ??
                        'A thoughtful guide to mastering new skills, building focus, and learning with intention. Explore practical ideas you can apply every day.',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Book information Section (Figma 04)
                  const Text(
                    'Book information',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoRow('Format', 'Paperback'),
                  const SizedBox(height: 10),
                  _buildInfoRow('Published', activeBook.firstPublishYear ?? '1994'),
                  const SizedBox(height: 10),
                  _buildInfoRow('Language', activeBook.language ?? 'EN'),
                  const SizedBox(height: 10),
                  _buildInfoRow('Editions', activeBook.editionCount?.toString() ?? '14'),
                  const SizedBox(height: 20),

                  // Subject chips
                  if (activeBook.subjects.isNotEmpty) ...[
                    const Text(
                      'Subjects',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeBook.subjects.take(4).map((sub) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.pillBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bottom Action Button (Figma rx 14, height 55, #3978D5)
                  CustomButton(
                    text: isFav ? 'Remove from Favorites' : 'Bookmark Favorite',
                    height: 55,
                    backgroundColor: isFav ? AppColors.danger : AppColors.secondary,
                    textColor: Colors.white,
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () async {
                      final added = await favoritesProvider.toggleFavorite(
                        activeBook,
                        userId: authProvider.currentUser?.uid,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(added
                                ? 'Saved "${activeBook.title}" to Favorites'
                                : 'Removed "${activeBook.title}" from Favorites'),
                            backgroundColor: added ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF17243A),
            ),
          ),
        ),
      ],
    );
  }
}
