import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../scripture/data/scripture_repository.dart';

/// Owns Explore's search state.
///
/// A ViewModel in MVVM terms: it orchestrates the repository and exposes
/// loading/error/success, and contains no widget code and no SQL.
///
/// Search runs on submit rather than on every keystroke. That is deliberate —
/// each query is a full `LIKE` scan of 31k verses, and Selah's pace is meant to
/// be unhurried rather than twitchy.
class ExploreSearchController extends Notifier<AsyncValue<SearchOutcome?>> {
  /// Null state means "nothing searched yet", which is distinct from a search
  /// that returned nothing — the UI shows categories vs. an empty state.
  @override
  AsyncValue<SearchOutcome?> build() => const AsyncValue.data(null);

  String _query = '';
  int _limit = AppConstants.searchPageSize;

  String get query => _query;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clear();
      return;
    }

    _query = trimmed;
    _limit = AppConstants.searchPageSize;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(scriptureRepositoryProvider).search(trimmed, limit: _limit),
    );
  }

  /// Widens the page and re-runs. Re-querying rather than appending keeps the
  /// results canonically ordered and the state a single immutable value; at ~33ms
  /// per scan the extra work is not worth the added complexity of merging.
  Future<void> loadMore() async {
    if (_query.isEmpty) return;
    final current = state.value;
    if (current is! KeywordMatch || !current.hasMore) return;

    _limit += AppConstants.searchPageSize;
    state = await AsyncValue.guard(
      () => ref.read(scriptureRepositoryProvider).search(_query, limit: _limit),
    );
  }

  void clear() {
    _query = '';
    _limit = AppConstants.searchPageSize;
    state = const AsyncValue.data(null);
  }
}

final exploreSearchProvider =
    NotifierProvider<ExploreSearchController, AsyncValue<SearchOutcome?>>(
      ExploreSearchController.new,
    );
