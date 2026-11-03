import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../models/book_model.dart';
import '../../../services/api_service.dart';
import '../providers/books_provider.dart';

/// Screen 7: API Integration Screen
/// Demonstrates live Open Library REST API fetching, response telemetry, and parsing
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
    final theme = Theme.of(context);
    final booksProvider = context.read<BooksProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.api_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Open Library API'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Query',
            onPressed: () => _fetchApiData(_queryController.text),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Info & Telemetry Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.lightBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'REST API • GET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_apiResult?.statusCode == 200 ? AppColors.success : AppColors.error)
                                .withValues(alpha: 0.15),
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
                    const SizedBox(height: 12),
                    Text(
                      'Endpoint:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: SelectableText(
                        _apiResult?.requestUrl.isNotEmpty ?? false
                            ? _apiResult!.requestUrl
                            : 'https://openlibrary.org/search.json?q=${_queryController.text}&limit=15',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Metrics Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricChip(
                          icon: Icons.timer_outlined,
                          label: 'Latency',
                          value: '${_apiResult?.responseTimeMs ?? 0} ms',
                        ),
                        _buildMetricChip(
                          icon: Icons.menu_book_rounded,
                          label: 'Catalog Items',
                          value: '${_apiResult?.totalFound ?? 0}',
                        ),
                        _buildMetricChip(
                          icon: Icons.format_list_numbered_rounded,
                          label: 'Fetched',
                          value: '${_apiResult?.data.length ?? 0}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Live Query Search Form
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Live Query',
                hintText: 'Enter search term...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                  onPressed: () => _fetchApiData(_queryController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onSubmitted: (q) => _fetchApiData(q),
            ),
            const SizedBox(height: 12),

            // Preset Query Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _presetQueries.map((preset) {
                final isSelected = _queryController.text == preset;
                return ActionChip(
                  label: Text(preset),
                  backgroundColor: isSelected ? AppColors.primary : null,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onPressed: () {
                    _queryController.text = preset;
                    _fetchApiData(preset);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Results Section
            Text(
              'Fetched API Results (${_apiResult?.data.length ?? 0} books)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: LoadingView(message: 'Communicating with Open Library REST API...'),
              )
            else if (_errorMessage != null)
              AppErrorWidget(
                message: _errorMessage!,
                onRetry: () => _fetchApiData(_queryController.text),
              )
            else if (_apiResult == null || _apiResult!.data.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: AppColors.lightTextSecondary),
                    SizedBox(height: 12),
                    Text('No API results returned for this query.'),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _apiResult!.data.length,
                itemBuilder: (context, index) {
                  final book = _apiResult!.data[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: book.coverUrl != null
                            ? Image.network(
                                book.coverUrl!,
                                width: 44,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, size: 32),
                              )
                            : const Icon(Icons.book, size: 32),
                      ),
                      title: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${book.authorDisplay} • ${book.firstPublishYear ?? 'N/A'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        booksProvider.selectBook(book);
                        context.push('/book-details');
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
