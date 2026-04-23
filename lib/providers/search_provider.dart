import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/services/firestore_service.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum SearchFilter { all, books, chapters }

class SearchState {
  final String query;
  final List<BookModel> bookResults;
  final List<ChapterModel> chapterResults;
  final bool isLoading;
  final String? error;
  final SearchFilter filter;
  final List<String> recentSearches;

  const SearchState({
    this.query = '',
    this.bookResults = const [],
    this.chapterResults = const [],
    this.isLoading = false,
    this.error,
    this.filter = SearchFilter.all,
    this.recentSearches = const [],
  });

  bool get hasQuery => query.trim().isNotEmpty;

  bool get hasResults => bookResults.isNotEmpty || chapterResults.isNotEmpty;

  int get totalResults => bookResults.length + chapterResults.length;

  List<BookModel> get filteredBooks =>
      filter == SearchFilter.chapters ? [] : bookResults;

  List<ChapterModel> get filteredChapters =>
      filter == SearchFilter.books ? [] : chapterResults;

  SearchState copyWith({
    String? query,
    List<BookModel>? bookResults,
    List<ChapterModel>? chapterResults,
    bool? isLoading,
    String? error,
    bool clearError = false,
    SearchFilter? filter,
    List<String>? recentSearches,
  }) {
    return SearchState(
      query: query ?? this.query,
      bookResults: bookResults ?? this.bookResults,
      chapterResults: chapterResults ?? this.chapterResults,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filter: filter ?? this.filter,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  Timer? _debounce;

  static const _debounceMs = 350;
  static const _maxRecent = 8;

  void setQuery(String query) {
    state = state.copyWith(
      query: query,
      isLoading: query.trim().isNotEmpty,
      clearError: true,
      bookResults: query.trim().isEmpty ? [] : state.bookResults,
      chapterResults: query.trim().isEmpty ? [] : state.chapterResults,
    );

    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _runSearch(query.trim()),
    );
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await Future.wait([
        FirestoreService.instance.searchBooks(query),
        FirestoreService.instance.searchChapters(query),
      ]);

      if (!mounted) return;
      state = state.copyWith(
        bookResults: results[0] as List<BookModel>,
        chapterResults: results[1] as List<ChapterModel>,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
        bookResults: [],
        chapterResults: [],
      );
    }
  }

  void setFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.recentSearches.where((s) => s != trimmed),
    ].take(_maxRecent).toList();

    state = state.copyWith(recentSearches: updated);
  }

  void removeRecent(String query) {
    state = state.copyWith(
      recentSearches: state.recentSearches.where((s) => s != query).toList(),
    );
  }

  void clearRecent() {
    state = state.copyWith(recentSearches: []);
  }

  void clearQuery() {
    _debounce?.cancel();
    state = state.copyWith(
      query: '',
      bookResults: [],
      chapterResults: [],
      isLoading: false,
      clearError: true,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
