import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../models/book_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../books/providers/books_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Task 13: Book Detail Screen Source Code (4 points)
class BookDetailScreen extends StatelessWidget {
  final BookModel? book;

  const BookDetailScreen({super.key, this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeBook = book ?? context.watch<BooksProvider>().selectedBook;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (activeBook == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined, size: 64, color: AppColors.lightTextSecondary),
              const SizedBox(height: 16),
              const Text('No book selected'),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Book Details'),
        actions: [
          // Quick Favorite Icon Action in AppBar
          IconButton(
            icon: Icon(
              isFav ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
              color: isFav ? AppColors.accent : null,
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
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Book',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sharing "${activeBook.title}"')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Cover Art Section
            Container(
              color: AppColors.primary.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Center(
                child: Hero(
                  tag: 'book_cover_${activeBook.id}',
                  child: Container(
                    width: 160,
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: activeBook.coverUrl != null && activeBook.coverUrl!.isNotEmpty
                          ? Image.network(
                              activeBook.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildCoverPlaceholder(),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: AppColors.lightDivider,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                            )
                          : _buildCoverPlaceholder(),
                    ),
                  ),
                ),
              ),
            ),

            // Book Details Container
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    activeBook.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Authors
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activeBook.authorDisplay,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Metadata Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetaBadge(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'Published',
                        value: activeBook.firstPublishYear ?? 'N/A',
                      ),
                      _buildMetaBadge(
                        context,
                        icon: Icons.language_rounded,
                        label: 'Language',
                        value: activeBook.language ?? 'EN',
                      ),
                      _buildMetaBadge(
                        context,
                        icon: Icons.auto_stories_outlined,
                        label: 'Editions',
                        value: activeBook.editionCount?.toString() ?? '1+',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Subject Chips
                  if (activeBook.subjects.isNotEmpty) ...[
                    Text(
                      'Subjects & Topics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeBook.subjects.take(6).map((sub) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Overview / Description
                  Text(
                    'Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeBook.description ??
                        'This academic resource is cataloged in the Open Library global database. It provides comprehensive study materials for ${activeBook.title}. Recommended for university coursework, technical reading, and skill enhancement.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons (Integrated with FavoritesProvider)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: isFav ? 'Saved in Favorites' : 'Bookmark Favorite',
                          icon: Icon(
                            isFav ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                            color: Colors.white,
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
                                      ? 'Saved "${activeBook.title}" to Favorites!'
                                      : 'Removed "${activeBook.title}" from Favorites'),
                                  backgroundColor: added ? AppColors.success : AppColors.error,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 54),
            SizedBox(height: 8),
            Text(
              'No Cover Art',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
