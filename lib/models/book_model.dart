/// Represents an educational book or learning resource from Open Library
class BookModel {
  final String id;
  final String title;
  final List<String> authors;
  final String? firstPublishYear;
  final String? coverUrl;
  final int? coverId;
  final String? description;
  final List<String> subjects;
  final int? editionCount;
  final String? language;

  const BookModel({
    required this.id,
    required this.title,
    required this.authors,
    this.firstPublishYear,
    this.coverUrl,
    this.coverId,
    this.description,
    this.subjects = const [],
    this.editionCount,
    this.language,
  });

  /// Factory constructor to parse Open Library Search API items
  factory BookModel.fromOpenLibraryJson(Map<String, dynamic> json) {
    // Extract ID (e.g. "key": "/works/OL45804W")
    final rawKey = json['key'] as String? ?? '';
    final id = rawKey.startsWith('/works/')
        ? rawKey.replaceFirst('/works/', '')
        : (rawKey.isNotEmpty ? rawKey : (json['cover_i']?.toString() ?? UniqueKey().toString()));

    // Authors array
    List<String> authorsList = [];
    if (json['author_name'] is List) {
      authorsList = (json['author_name'] as List).map((e) => e.toString()).toList();
    } else if (json['author_name'] is String) {
      authorsList = [json['author_name'] as String];
    }
    if (authorsList.isEmpty) {
      authorsList = ['Unknown Author'];
    }

    // Cover ID & URL (Open Library Covers API)
    final coverId = json['cover_i'] is int ? json['cover_i'] as int : null;
    String? coverUrl;
    if (coverId != null && coverId > 0) {
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    } else if (json['cover_url'] is String && (json['cover_url'] as String).isNotEmpty) {
      coverUrl = json['cover_url'] as String;
    }

    // Subjects
    List<String> subjectsList = [];
    if (json['subject'] is List) {
      subjectsList = (json['subject'] as List).take(8).map((e) => e.toString()).toList();
    }

    // Publish year
    String? publishYear;
    if (json['first_publish_year'] != null) {
      publishYear = json['first_publish_year'].toString();
    }

    // Languages
    String? language;
    if (json['language'] is List && (json['language'] as List).isNotEmpty) {
      language = (json['language'] as List).first.toString().toUpperCase();
    }

    // Description (if present in work detail)
    String? description;
    if (json['description'] is String) {
      description = json['description'] as String;
    } else if (json['description'] is Map && json['description']['value'] is String) {
      description = json['description']['value'] as String;
    }

    return BookModel(
      id: id,
      title: json['title'] as String? ?? 'Untitled Book',
      authors: authorsList,
      firstPublishYear: publishYear,
      coverUrl: coverUrl,
      coverId: coverId,
      description: description,
      subjects: subjectsList,
      editionCount: json['edition_count'] is int ? json['edition_count'] as int : null,
      language: language ?? 'EN',
    );
  }

  /// JSON serialization for local caching and Firestore favorites
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Book',
      authors: (json['authors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Unknown Author'],
      firstPublishYear: json['firstPublishYear']?.toString(),
      coverUrl: json['coverUrl'] as String?,
      coverId: json['coverId'] is int ? json['coverId'] as int : null,
      description: json['description'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      editionCount: json['editionCount'] is int ? json['editionCount'] as int : null,
      language: json['language'] as String? ?? 'EN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'firstPublishYear': firstPublishYear,
      'coverUrl': coverUrl,
      'coverId': coverId,
      'description': description,
      'subjects': subjects,
      'editionCount': editionCount,
      'language': language,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'author': authors.isNotEmpty ? authors.first : 'Unknown Author',
      'authors': authors,
      'coverUrl': coverUrl ?? '',
      'firstPublishYear': firstPublishYear ?? '',
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  String get authorDisplay => authors.join(', ');
}

class UniqueKey {
  static int _counter = 0;
  @override
  String toString() => 'gen_${DateTime.now().millisecondsSinceEpoch}_${++_counter}';
}

