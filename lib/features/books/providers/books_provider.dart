import 'package:flutter/foundation.dart';
import '../../../core/errors/exceptions.dart';
import '../../../models/book_model.dart';
import '../../../services/api_service.dart';

/// Provider managing book discovery, search, and category filtering
class BooksProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<BookModel> _featuredBooks = [];
  List<BookModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = '';
  String _selectedCategory = 'All';
  BookModel? _selectedBook;

  final List<String> categories = const [
    'All',
    'Flutter',
    'Computer Science',
    'Programming',
    'Artificial Intelligence',
    'Mathematics',
    'Mobile Development',
  ];

  BooksProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    loadInitialBooks();
  }

  List<BookModel> get featuredBooks => _featuredBooks;
  List<BookModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;
  String get selectedCategory => _selectedCategory;
  BookModel? get selectedBook => _selectedBook;

  bool get isSearching => _currentQuery.trim().isNotEmpty;

  List<BookModel> get displayBooks => isSearching ? _searchResults : _featuredBooks;

  /// Loads initial discovery books
  Future<void> loadInitialBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _featuredBooks = await _apiService.getFeaturedBooks(limit: 20);
      _errorMessage = null;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load discovery books: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Searches books with custom user query
  Future<void> searchBooks(String query) async {
    final cleanQuery = query.trim();
    _currentQuery = cleanQuery;

    if (cleanQuery.isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchBooks(cleanQuery, limit: 25);
      _errorMessage = null;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } on ServerException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Search error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters books by category
  Future<void> selectCategory(String category) async {
    _selectedCategory = category;
    _currentQuery = '';
    _searchResults = [];

    if (category == 'All') {
      await loadInitialBooks();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _featuredBooks = await _apiService.getBooksByCategory(category, limit: 20);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load category books: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a book for detail navigation
  void selectBook(BookModel book) {
    _selectedBook = book;
    notifyListeners();
  }

  /// Clears active search filter
  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }
}
