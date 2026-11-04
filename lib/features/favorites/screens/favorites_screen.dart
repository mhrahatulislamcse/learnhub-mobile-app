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

/// Screen 5: Favorites Screen & Profile
/// Replicates Figma Screen 05 (My library) with SharedPreferences and Firestore persistence
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final booksProvider = context.read<BooksProvider>();
    final user = authProvider.currentUser;
    final username = user?.username.isNotEmpty ?? false ? user!.username : 'Rahatul Islam';
    final userInitial = username.isNotEmpty ? username[0].toUpperCase() : 'R';
    final role = user?.role == 'admin' ? 'Administrator' : 'Learning enthusiast';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Favorites',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (favoritesProvider.count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${favoritesProvider.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightTextSecondary),
            tooltip: 'Sync Favorites',
            onPressed: () {
              favoritesProvider.loadFavorites(userId: user?.uid);
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
              : ListView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                  children: [
                    // Figma 05 Headline: My library
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'My library',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Your saved reads, all in one place.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Figma 05: Profile Card (White, rx 14, border #E7ECF3, height 82)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: InkWell(
                          onTap: () => context.push('/profile'),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: AppColors.pillBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    userInitial,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      role,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Figma 05: Saved books section & filter pills
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Saved books',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildFilterChip(0, 'All (${favoritesProvider.count})'),
                          const SizedBox(width: 8),
                          _buildFilterChip(1, 'Reading'),
                          const SizedBox(width: 8),
                          _buildFilterChip(2, 'Completed'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // List of saved books rendered using BookCard (for test compatibility & Figma design)
                    ...favoritesProvider.favorites.map((book) {
                      return BookCard(
                        book: book,
                        onTap: () {
                          booksProvider.selectBook(book);
                          context.push('/book-details');
                        },
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.bookmark_remove_rounded,
                            color: AppColors.heartPink,
                          ),
                          tooltip: 'Remove from Favorites',
                          onPressed: () {
                            favoritesProvider.removeFavorite(
                              book.id,
                              userId: user?.uid,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed "${book.title}" from favorites'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    favoritesProvider.addFavorite(book, userId: user?.uid);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.lightTextSecondary,
          ),
        ),
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
              decoration: const BoxDecoration(
                color: AppColors.pillBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Saved Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Explore books from the Home dashboard and tap the bookmark button to save them to your personal reading list.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Browse Books',
              backgroundColor: AppColors.secondary,
              textColor: Colors.white,
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
