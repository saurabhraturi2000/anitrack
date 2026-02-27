// get the current animes and split them into 2 groups one releasing and the finished ones.

import 'package:anitrack/models/collection_model.dart';
import 'package:anitrack/models/media_model.dart';
import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/auth_provider.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentAnimesProvider = FutureProvider((ref) async {
  final user = ref.watch(userProvider);
  final data = await ApiService().request(GqlQuery.currentAnimes, {
    "userId": user?.id,
    "type": "ANIME",
    "status": "CURRENT",
  });
  final currentAnime = CollectionModel.fromJson(data);
  final entries = currentAnime.mediaListCollection?.lists
          ?.expand((list) => list.entries ?? const <Entry>[])
          .where((entry) => entry.media != null)
          .toList() ??
      const <Entry>[];

  // Divide into releasing and finished lists
  final releasingAnimes = entries
      .where((anime) => anime.media?.status == Status.RELEASING)
      .toList();

  final finishedAnimes =
      entries.where((anime) => anime.media?.status == Status.FINISHED).toList();
  return {
    "releasing": releasingAnimes,
    "finished": finishedAnimes,
  };
});

final currentMangasProvider = FutureProvider((ref) async {
  final user = ref.watch(userProvider);
  final data = await ApiService().request(GqlQuery.currentAnimes, {
    "userId": user?.id,
    "type": "MANGA",
    "status": "CURRENT",
  });
  final currentManga = CollectionModel.fromJson(data);
  final entries = currentManga.mediaListCollection?.lists
          ?.expand((list) => list.entries ?? const <Entry>[])
          .where((entry) => entry.media != null)
          .toList() ??
      const <Entry>[];

  final releasingMangas = entries
      .where((manga) => manga.media?.status == Status.RELEASING)
      .toList();

  final finishedMangas =
      entries.where((manga) => manga.media?.status == Status.FINISHED).toList();

  return {
    "releasing": releasingMangas,
    "finished": finishedMangas,
  };
});

class CurrentMangaFeedState {
  const CurrentMangaFeedState({
    this.releasingEntries = const <Entry>[],
    this.finishedEntries = const <Entry>[],
    this.phase = MangaLoadPhase.releasing,
    this.page = 0,
    this.hasMore = true,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Entry> releasingEntries;
  final List<Entry> finishedEntries;
  final MangaLoadPhase phase;
  final int page;
  final bool hasMore;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  CurrentMangaFeedState copyWith({
    List<Entry>? releasingEntries,
    List<Entry>? finishedEntries,
    MangaLoadPhase? phase,
    int? page,
    bool? hasMore,
    bool? isInitialLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CurrentMangaFeedState(
      releasingEntries: releasingEntries ?? this.releasingEntries,
      finishedEntries: finishedEntries ?? this.finishedEntries,
      phase: phase ?? this.phase,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum MangaLoadPhase { releasing, finished, done }

final currentMangaFeedProvider =
    StateNotifierProvider<CurrentMangaFeedNotifier, CurrentMangaFeedState>(
  (ref) => CurrentMangaFeedNotifier(ref),
);

class CurrentMangaFeedNotifier extends StateNotifier<CurrentMangaFeedState> {
  CurrentMangaFeedNotifier(this._ref) : super(const CurrentMangaFeedState()) {
    _loadInitial();
  }

  static const int _perPage = 15;

  final Ref _ref;

  Future<void> _loadInitial() async {
    final user = _ref.read(userProvider);
    if (user == null) {
      state = const CurrentMangaFeedState(
        releasingEntries: <Entry>[],
        finishedEntries: <Entry>[],
        phase: MangaLoadPhase.done,
        hasMore: false,
      );
      return;
    }

    state = state.copyWith(
      isInitialLoading: true,
      clearError: true,
      releasingEntries: <Entry>[],
      finishedEntries: <Entry>[],
      phase: MangaLoadPhase.releasing,
      page: 0,
      hasMore: true,
    );

    try {
      state = state.copyWith(isInitialLoading: false);
      await loadMore();
    } catch (e) {
      state = state.copyWith(
        isInitialLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    if (state.isInitialLoading ||
        state.isLoadingMore ||
        state.phase == MangaLoadPhase.done) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      await _loadNextPhasePage();
      state = state.copyWith(isLoadingMore: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _loadNextPhasePage() async {
    if (state.phase == MangaLoadPhase.done) return;
    if (!state.hasMore) {
      await _switchToNextPhaseAndPrefetch();
      return;
    }

    final page = state.page + 1;
    final phase = state.phase;
    final status = phase == MangaLoadPhase.releasing ? 'CURRENT' : 'COMPLETED';

    final user = _ref.read(userProvider);
    if (user == null) {
      state = state.copyWith(
        phase: MangaLoadPhase.done,
        hasMore: false,
      );
      return;
    }

    final data = await ApiService().request(
      GqlQuery.currentMangaPage,
      {
        'userId': user.id,
        'page': page,
        'perPage': _perPage,
        'status': status,
      },
    );

    final pageData = data['Page'] as Map<String, dynamic>? ?? const {};
    final pageInfo = pageData['pageInfo'] as Map<String, dynamic>? ?? const {};
    final items = (pageData['mediaList'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((json) => Entry.fromJson(Map<String, dynamic>.from(json)))
        .toList(growable: false);

    final hasNextPage = pageInfo['hasNextPage'] == true;
    if (phase == MangaLoadPhase.releasing) {
      final filtered = items
          .where((manga) => manga.media?.status == Status.RELEASING)
          .toList(growable: false);
      final merged = List<Entry>.from(state.releasingEntries)..addAll(filtered);
      state = state.copyWith(
        releasingEntries: merged,
        page: page,
        hasMore: hasNextPage,
      );
    } else {
      final filtered = items
          .where((manga) => manga.media?.status == Status.FINISHED)
          .toList(growable: false);
      final merged = List<Entry>.from(state.finishedEntries)..addAll(filtered);
      state = state.copyWith(
        finishedEntries: merged,
        page: page,
        hasMore: hasNextPage,
      );
    }

    if (!hasNextPage) {
      await _switchToNextPhaseAndPrefetch();
    }
  }

  Future<void> _switchToNextPhaseAndPrefetch() async {
    if (state.phase == MangaLoadPhase.releasing) {
      state = state.copyWith(
        phase: MangaLoadPhase.finished,
        page: 0,
        hasMore: true,
      );
      await _loadNextPhasePage();
      return;
    }

    if (state.phase == MangaLoadPhase.finished) {
      state = state.copyWith(
        phase: MangaLoadPhase.done,
        page: 0,
        hasMore: false,
      );
      return;
    }
  }
}

extension CurrentMangaFeedViewState on CurrentMangaFeedState {
  bool get showFinishedSection =>
      phase != MangaLoadPhase.releasing || finishedEntries.isNotEmpty;

  bool get hasLoadedAnything =>
      releasingEntries.isNotEmpty || finishedEntries.isNotEmpty;
}

