import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/book_cover_widget.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../models/book_model.dart';
import '../../../services/api_service.dart';
import '../providers/books_provider.dart';

/// Screen 7: API Integration Screen
/// Replicates Figma Screen 06 (Discover books / External API) with live Open Library REST telemetry
class ApiIntegrationScreen extends StatefulWidget {
  final ApiService? apiService;

  const ApiIntegrationScreen({super.key, this.apiService});

  @override
  State<ApiIntegrationScreen> createState() => _ApiIntegrationScreenState();
}

class _ApiIntegrationScreenState extends State<ApiIntegrationScreen> {
  late final ApiService _apiService;
  final _queryController = TextEditingController(text: 'flutter');

  bool _isLoading = false;
  String? _errorMessage;
  ApiResult<List<BookModel>>? _apiResult;

  final List<String> _presetQueries = const [
    'flutter',
    'dart programming',
    'machine learning',
    'algorithms',
    'clean code',
    'data structures',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _fetchApiData('flutter');
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _fetchApiData(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.searchBooksWithMetadata(cleanQuery, limit: 15);
      if (mounted) {
        setState(() {
          _apiResult = result;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.read<BooksProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Open Library API',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.lightTextSecondary),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightTextSecondary),
            tooltip: 'Refresh Query',
            onPressed: () => _fetchApiData(_queryController.text),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Figma 06 Heading: Find your next great read.
            const Text(
              'Find your next\ngreat read.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Search Input (Figma 06: rx 13, border #E7ECF3, height 50)
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Icon(Icons.search_rounded, color: AppColors.lightTextSecondary, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _fetchApiData,
                      style: const TextStyle(fontSize: 13, color: AppColors.lightTextPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search title, author or ISBN',
                        hintStyle: TextStyle(
                          color: AppColors.placeholder,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_queryController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.lightTextSecondary),
                      onPressed: () {
                        _queryController.clear();
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Preset Topic Filter Chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presetQueries.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final preset = _presetQueries[index];
                  final isCurrent = _queryController.text.trim().toLowerCase() == preset.toLowerCase();
                  return InkWell(
                    onTap: () {
                      _queryController.text = preset;
                      _fetchApiData(preset);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.secondary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? AppColors.secondary : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        preset,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? Colors.white : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // API Info & Telemetry Card (Task 19 & 20)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.pillBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'REST API • GET',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_apiResult?.statusCode == 200 ? AppColors.success : AppColors.error)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _apiResult != null ? 'Status: ${_apiResult!.statusCode} OK' : 'Status: Idle',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _apiResult?.statusCode == 200 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _apiResult?.requestUrl.isNotEmpty ?? false
                        ? _apiResult!.requestUrl
                        : 'https://openlibrary.org/search.json?q=${_queryController.text}&limit=15',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.lightBorder, height: 1),
                  const SizedBox(height: 12),

                  // Metrics Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricChip('Latency', '${_apiResult?.responseTimeMs ?? 0} ms'),
                      _buildMetricChip('Catalog Items', '${_apiResult?.totalFound ?? 0}'),
                      _buildMetricChip('Fetched', '${_apiResult?.data.length ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results Header (Figma 06: Results from Open Library + X results)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Results from Open Library',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${_apiResult?.data.length ?? 0} results',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content Area: Loading, Error, or Result Cards
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: LoadingView(message: 'Querying Open Library endpoint...'),
              )
            else if (_errorMessage != null)
              AppErrorWidget(
                title: 'API Request Error',
                message: _errorMessage!,
                onRetry: () => _fetchApiData(_queryController.text),
              )
            else if (_apiResult?.data.isEmpty ?? true)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 40, color: AppColors.lightTextSecondary),
                    SizedBox(height: 8),
                    Text(
                      'No matching books found in Open Library.',
                      style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              // Figma 06 Card List: height 106, rx 13, BookCoverWidget 61x88
              ..._apiResult!.data.map((book) {
                return Container(
                  height: 106,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: InkWell(
                    onTap: () {
                      booksProvider.selectBook(book);
                      context.push('/book-details');
                    },
                    child: Row(
                      children: [
                        BookCoverWidget(
                          title: book.title,
                          coverUrl: book.coverUrl,
                          width: 61,
                          height: 88,
                          borderRadius: 9,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                book.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.authorDisplay,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'API result  ·  View details',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Footer (Figma 06)
            const Center(
              child: Text(
                'Data source: Open Library API',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
