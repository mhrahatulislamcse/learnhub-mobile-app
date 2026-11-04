import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/book_cover_widget.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../models/book_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../books/providers/books_provider.dart';
import '../../settings/widgets/settings_drawer.dart';
import '../widgets/book_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/search_bar_widget.dart';

/// Task 11: Home Screen Source Code (4 points)
/// Replicates Figma Screen 03 (Home Dashboard) with navigation and live Open Library integration
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentNavIndex = 0;

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

  void _onBottomNavTapped(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 1) {
      context.push('/api-integration');
    } else if (index == 2) {
      context.push('/favorites');
    } else if (index == 3) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.push('/profile');
      } else {
        context.push('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final booksProvider = context.watch<BooksProvider>();
    final user = authProvider.currentUser;
    final username = user?.username.isNotEmpty ?? false ? user!.username : 'Rahat';
    final userInitial = username.isNotEmpty ? username[0].toUpperCase() : 'R';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            tooltip: 'Open Settings Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.pillBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_stories_rounded, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          // API explorer shortcut
          IconButton(
            icon: const Icon(Icons.api_rounded, color: AppColors.lightTextSecondary),
            tooltip: 'Open Library API',
            onPressed: () => context.push('/api-integration'),
          ),
          // User Avatar (Figma circle cx=348 r=20 fill=#EAF1FC text=#3978D5 'R')
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GestureDetector(
              onTap: () {
                if (authProvider.isAuthenticated) {
                  context.push('/profile');
                } else {
                  context.push('/login');
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.pillBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
            // Figma 03: Greeting & Headline Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $username 👋',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'What will you learn\ntoday?',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar Widget (Figma 03: rx 13, #E7ECF3 border)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SearchBarWidget(
                  controller: _searchController,
                  onSubmitted: _onSearch,
                  onClear: _onClearSearch,
                ),
              ),
            ),

            // Explore Categories Section (Figma 03: Explore categories heading + chips)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'Explore categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
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

            // Featured For You Section (Figma 03 Card)
            if (!booksProvider.isSearching && booksProvider.displayBooks.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured for you',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/api-integration'),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: _buildFeaturedCard(context),
                ),
              ),
            ],

            // Popular This Week Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booksProvider.isSearching
                          ? 'Search Results for "${booksProvider.currentQuery}"'
                          : 'Popular this week',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${booksProvider.displayBooks.length} items',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area: Loading, Error, Empty, or Book List
            if (booksProvider.isLoading)
              const SliverFillRemaining(
                child: LoadingView(message: 'Connecting to Open Library API...'),
              )
            else if (booksProvider.errorMessage != null)
              SliverFillRemaining(
                child: AppErrorWidget(
                  title: 'Could Not Load Books',
                  message: booksProvider.errorMessage!,
                  onRetry: () => booksProvider.loadInitialBooks(),
                ),
              )
            else if (booksProvider.displayBooks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 54, color: AppColors.lightTextSecondary),
                        const SizedBox(height: 12),
                        const Text(
                          'No books found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try searching for another topic or author.',
                          style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onClearSearch,
                          child: const Text('Reset Search'),
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
                        booksProvider.selectBook(book);
                        context.push('/book-details');
                      },
                    );
                  },
                  childCount: booksProvider.displayBooks.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      // Figma 03 Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.lightBorder, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.explore_outlined, 'Explore'),
                _buildNavItem(2, Icons.favorite_outline_rounded, 'Saved'),
                _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    final color = isSelected ? AppColors.secondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: () => _onBottomNavTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1),
      ),
      child: InkWell(
        onTap: () => context.push('/api-integration'),
        child: Row(
          children: [
            // Book Cover (100 x 136)
            const BookCoverWidget(
              title: 'The Art of Learning',
              width: 100,
              height: 136,
              borderRadius: 9,
              backgroundColor: AppColors.coverBlue,
              textColor: AppColors.coverBlueText,
            ),
            const SizedBox(width: 16),

            // Details on the right (Figma 03: The Art of Learning)
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EDITOR'S PICK",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The Art of Learning',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'A practical guide to lifelong growth.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.accentGold, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '4.8  ·  240 pages',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
