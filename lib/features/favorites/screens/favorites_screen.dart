import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../../books/providers/books_provider.dart';
import '../../home/widgets/book_card.dart';
import '../providers/favorites_provider.dart';

/// Screen 5: Favorites Screen
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final booksProvider = context.read<BooksProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmarks_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            const Text('My Favorites'),
            if (favoritesProvider.count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${favoritesProvider.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sync Favorites',
            onPressed: () {
              favoritesProvider.loadFavorites(
                userId: authProvider.currentUser?.uid,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites synchronized')),
              );
            },
          ),
        ],
      ),
      body: favoritesProvider.isLoading
          ? const LoadingView(message: 'Loading your saved books...')
          : favoritesProvider.favorites.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  itemCount: favoritesProvider.favorites.length,
                  itemBuilder: (context, index) {
                    final book = favoritesProvider.favorites[index];
                    return BookCard(
                      book: book,
                      onTap: () {
                        booksProvider.selectBook(book);
                        context.push('/book-details');
                      },
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.bookmark_remove_rounded,
                          color: AppColors.error,
                        ),
                        tooltip: 'Remove from Favorites',
                        onPressed: () {
                          favoritesProvider.removeFavorite(
                            book.id,
                            userId: authProvider.currentUser?.uid,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "${book.title}" from favorites'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  favoritesProvider.addFavorite(
                                    book,
                                    userId: authProvider.currentUser?.uid,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorites Saved Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Explore books from the Home dashboard and tap the bookmark button to save them to your personal reading list.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Browse Books',
              icon: const Icon(Icons.explore_outlined, color: Colors.white),
              width: 200,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
