import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../../books/providers/books_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/search_bar_widget.dart';

/// Task 11: Home Screen Source Code (4 points)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<BooksProvider>().searchBooks(query);
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<BooksProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final booksProvider = context.watch<BooksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // API Explorer Shortcut (Task 19/20)
          IconButton(
            icon: const Icon(Icons.api_rounded),
            tooltip: 'Open Library API',
            onPressed: () => context.push('/api-integration'),
          ),
          // Favorites Shortcut
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: 'My Favorites',
            onPressed: () => context.push('/favorites'),
          ),
          // User Avatar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (authProvider.isAuthenticated) {
                  context.push('/profile');
                } else {
                  context.push('/login');
                }
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  authProvider.currentUser?.username.isNotEmpty ?? false
                      ? authProvider.currentUser!.username[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (booksProvider.isSearching) {
            await booksProvider.searchBooks(booksProvider.currentQuery);
          } else {
            await booksProvider.loadInitialBooks();
          }
        },
        child: CustomScrollView(
          slivers: [
            // Welcome & Discovery Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${authProvider.currentUser?.username ?? 'Learner'} 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Explore global educational books and academic resources from Open Library.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar Widget
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SearchBarWidget(
                  controller: _searchController,
                  onSubmitted: _onSearch,
                  onClear: _onClearSearch,
                ),
              ),
            ),

            // Category Chips Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CategorySelector(
                  categories: booksProvider.categories,
                  selectedCategory: booksProvider.selectedCategory,
                  onSelectCategory: (cat) {
                    _searchController.clear();
                    booksProvider.selectCategory(cat);
                  },
                ),
              ),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booksProvider.isSearching
                          ? 'Search Results for "${booksProvider.currentQuery}"'
                          : '${booksProvider.selectedCategory} Resources',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${booksProvider.displayBooks.length} items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area: Loading, Error, Empty, or Book List
            if (booksProvider.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingView(message: 'Fetching educational books from Open Library...'),
              )
            else if (booksProvider.errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorWidget(
                  message: booksProvider.errorMessage!,
                  onRetry: () {
                    if (booksProvider.isSearching) {
                      booksProvider.searchBooks(booksProvider.currentQuery);
                    } else {
                      booksProvider.loadInitialBooks();
                    }
                  },
                ),
              )
            else if (booksProvider.displayBooks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Books Found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try searching for another topic like "Dart", "Machine Learning", or "Algorithms".',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset Search'),
                          onPressed: _onClearSearch,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = booksProvider.displayBooks[index];
                    return BookCard(
                      book: book,
                      onTap: () {
                        // Task 14: Detail Navigation Trigger
                        booksProvider.selectBook(book);
                        context.push('/book-details');
                      },
                    );
                  },
                  childCount: booksProvider.displayBooks.length,
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}

