import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/errors/exceptions.dart';
import '../core/utils/app_logger.dart';
import '../models/book_model.dart';

/// Service interfacing with Open Library REST API (Section 8)
class ApiService {
  final http.Client _client;
  static const String _baseUrl = 'https://openlibrary.org';

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches Open Library books by query string
  Future<List<BookModel>> searchBooks(String query, {int limit = 20}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    final encodedQuery = Uri.encodeComponent(cleanQuery);
    final url = Uri.parse('$_baseUrl/search.json?q=$encodedQuery&limit=$limit');

    AppLogger.info('ApiService: Fetching books from $url');

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final docs = data['docs'] as List<dynamic>? ?? [];

        return docs.map((doc) => BookModel.fromOpenLibraryJson(doc as Map<String, dynamic>)).toList();
      } else {
        AppLogger.error('ApiService: HTTP Error ${response.statusCode}: ${response.body}');
        throw ServerException(
          message: 'Server returned error ${response.statusCode}. Please try again later.',
        );
      }
    } on http.ClientException catch (e) {
      AppLogger.error('ApiService: Network ClientException: $e');
      throw const NetworkException(message: 'Network connection failed. Please check your internet connection.');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      AppLogger.error('ApiService: Unexpected API error: $e');
      throw ServerException(message: 'Failed to retrieve books from Open Library: $e');
    }
  }

  /// Fetches featured educational books (default query: "flutter programming")
  Future<List<BookModel>> getFeaturedBooks({int limit = 15}) async {
    return await searchBooks('flutter programming', limit: limit);
  }

  /// Fetches books by subject category (e.g. computer_science, mathematics)
  Future<List<BookModel>> getBooksByCategory(String category, {int limit = 15}) async {
    final cleanCategory = category.trim().toLowerCase().replaceAll(' ', '+');
    return await searchBooks(cleanCategory, limit: limit);
  }
}
