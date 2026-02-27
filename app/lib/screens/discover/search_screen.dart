import 'dart:async';

import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/app_colors.dart';
import 'package:anitrack/utils/appearance_theme.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:anitrack/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.initialCategory,
    this.scope,
  });

  final String? initialCategory;
  final String? scope;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  Timer? _debounce;

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _results = const [];
  late _SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _filters = _SearchFilters(
      genre: widget.initialCategory,
      type: _scopeToType(widget.scope),
      sort: 'SEARCH_MATCH',
      isAdult: false,
    );
    if (_filters.genre != null || _filters.type != null) {
      _runSearch();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final activeFilterCount = _filters.activeCount;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilterDrawer,
        backgroundColor: colors.accent,
        foregroundColor: colors.actionText,
        icon: const Icon(Icons.tune),
        label: Text(activeFilterCount == 0
            ? 'FILTER'
            : 'FILTER ($activeFilterCount)'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              color: colors.background,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(Icons.arrow_back, color: colors.iconMuted),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(color: colors.textMuted),
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => _scheduleSearch(),
                          onSubmitted: (_) => _runSearch(),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Search anime or manga...',
                            hintStyle: TextStyle(color: colors.iconMuted),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _runSearch,
                        icon: Icon(Icons.search, color: colors.iconMuted),
                      ),
                    ],
                  ),
                  if (_filters.genre != null || _filters.type != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_filters.genre != null)
                              Text(
                                _filters.genre!,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            if (_filters.genre != null && _filters.type != null)
                              Text(
                                '  |  ',
                                style: TextStyle(
                                  color: colors.iconMuted,
                                  fontSize: 14,
                                ),
                              ),
                            if (_filters.type != null)
                              Text(
                                _filters.type!,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: _buildBody(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppPalette colors) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.textMuted,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted),
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      final hasInput = _controller.text.trim().isNotEmpty || _filters.activeCount > 0;
      return Center(
        child: Text(
          hasInput ? 'No results found.' : 'Type to search.',
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 88),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _results[index];
        final id = (item['id'] as num?)?.toInt();
        final type = item['type']?.toString();
        final titleData = item['title'] as Map<String, dynamic>? ?? const {};
        final title = titleData['english']?.toString().trim().isNotEmpty == true
            ? titleData['english'].toString()
            : (titleData['romaji']?.toString() ?? 'Untitled');
        final cover = (item['coverImage'] as Map<String, dynamic>?)?['large'];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: (id == null || type == null)
              ? null
              : () {
                  final route =
                      type == 'MANGA' ? Routes.mangaDetail : Routes.animeDetail;
                  context.push('$route/$id');
                },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 52,
                    height: 74,
                    child: cover == null
                        ? ColoredBox(color: colors.surfaceAlt)
                        : Image.network(
                            cover.toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                ColoredBox(color: colors.surfaceAlt),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item['type'] ?? '-'}  |  ${item['format'] ?? '-'}',
                        style: TextStyle(color: colors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _runSearch);
  }

  Future<void> _runSearch() async {
    final term = _controller.text.trim();
    if (term.isEmpty && _filters.activeCount == 0) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _results = const [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> data;
      try {
        data = await ApiService().request(
          GqlQuery.searchMedia,
          _filters.toVariables(search: term),
        );
      } catch (e) {
        final message = e.toString();
        final isServerError = message.contains('Internal Server Error');
        if (!isServerError) rethrow;

        // Fallback to a reduced variable set for AniList edge-case failures.
        data = await ApiService().request(
          GqlQuery.searchMedia,
          _filters.toSafeVariables(search: term),
        );
      }

      final page = data['Page'] as Map<String, dynamic>?;
      final list = (page?['media'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _results = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _results = const [];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openFilterDrawer() async {
    final draft = _filters.copy();
    final yearController =
        TextEditingController(text: draft.seasonYear?.toString() ?? '');
    final minScoreController =
        TextEditingController(text: draft.averageScoreGreater?.toString() ?? '');
    final minProgressController =
        TextEditingController(text: draft.progressGreater?.toString() ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        final colors = AppColors.of(bottomSheetContext);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AniList Filters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _dropdown(
                        label: 'Type',
                        value: draft.type,
                        options: const ['ANIME', 'MANGA'],
                        onChanged: (v) => setModalState(() => draft.type = v),
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Genre',
                        value: draft.genre,
                        options: _genres,
                        onChanged: (v) => setModalState(() => draft.genre = v),
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Format',
                        value: draft.format,
                        options: const [
                          'TV',
                          'TV_SHORT',
                          'MOVIE',
                          'SPECIAL',
                          'OVA',
                          'ONA',
                          'MUSIC',
                          'MANGA',
                          'NOVEL',
                          'ONE_SHOT',
                        ],
                        onChanged: (v) => setModalState(() => draft.format = v),
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Status',
                        value: draft.status,
                        options: const [
                          'FINISHED',
                          'RELEASING',
                          'NOT_YET_RELEASED',
                          'CANCELLED',
                          'HIATUS',
                        ],
                        onChanged: (v) => setModalState(() => draft.status = v),
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Season',
                        value: draft.season,
                        options: const ['WINTER', 'SPRING', 'SUMMER', 'FALL'],
                        onChanged: (v) => setModalState(() => draft.season = v),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Season Year',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Country',
                        value: draft.countryOfOrigin,
                        options: const ['JP', 'KR', 'CN', 'TW', 'US'],
                        onChanged: (v) =>
                            setModalState(() => draft.countryOfOrigin = v),
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Sort',
                        value: draft.sort,
                        options: const [
                          'SEARCH_MATCH',
                          'POPULARITY_DESC',
                          'SCORE_DESC',
                          'TRENDING_DESC',
                          'START_DATE_DESC',
                          'ID_DESC',
                        ],
                        onChanged: (v) => setModalState(() => draft.sort = v),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: minScoreController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min Score (0-100)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: minProgressController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: draft.type == 'MANGA'
                              ? 'Min Chapters'
                              : 'Min Episodes',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        value: draft.isAdult ?? false,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Include Adult'),
                        onChanged: (v) => setModalState(() => draft.isAdult = v),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  draft.reset();
                                  yearController.clear();
                                  minScoreController.clear();
                                  minProgressController.clear();
                                });
                              },
                              child: const Text('Clear'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.accent,
                                foregroundColor: colors.actionText,
                              ),
                              onPressed: () {
                                draft.seasonYear =
                                    int.tryParse(yearController.text.trim());
                                draft.averageScoreGreater =
                                    int.tryParse(minScoreController.text.trim());
                                draft.progressGreater =
                                    int.tryParse(minProgressController.text.trim());
                                setState(() => _filters = draft.copy());
                                Navigator.of(bottomSheetContext).pop();
                                _runSearch();
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map(
            (opt) => DropdownMenuItem<String>(
              value: opt,
              child: Text(opt),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String? _scopeToType(String? scope) {
    if (scope == null) return null;
    switch (scope.toLowerCase()) {
      case 'anime':
        return 'ANIME';
      case 'manga':
        return 'MANGA';
      default:
        return null;
    }
  }
}

class _SearchFilters {
  _SearchFilters({
    this.type,
    this.genre,
    this.format,
    this.status,
    this.season,
    this.seasonYear,
    this.countryOfOrigin,
    this.sort,
    this.averageScoreGreater,
    this.progressGreater,
    this.isAdult,
  });

  String? type;
  String? genre;
  String? format;
  String? status;
  String? season;
  int? seasonYear;
  String? countryOfOrigin;
  String? sort;
  int? averageScoreGreater;
  int? progressGreater;
  bool? isAdult;

  int get activeCount {
    final fields = [
      type,
      genre,
      format,
      status,
      season,
      seasonYear,
      countryOfOrigin,
      sort != null && sort != 'SEARCH_MATCH' ? sort : null,
      averageScoreGreater,
      progressGreater,
      isAdult == true ? true : null,
    ];
    return fields.where((e) => e != null).length;
  }

  _SearchFilters copy() => _SearchFilters(
        type: type,
        genre: genre,
        format: format,
        status: status,
        season: season,
        seasonYear: seasonYear,
        countryOfOrigin: countryOfOrigin,
        sort: sort,
        averageScoreGreater: averageScoreGreater,
        progressGreater: progressGreater,
        isAdult: isAdult,
      );

  void reset() {
    type = null;
    genre = null;
    format = null;
    status = null;
    season = null;
    seasonYear = null;
    countryOfOrigin = null;
    sort = 'SEARCH_MATCH';
    averageScoreGreater = null;
    progressGreater = null;
    isAdult = false;
  }

  Map<String, dynamic> toVariables({required String search}) {
    final effectiveSort = (sort == null || sort!.isEmpty)
        ? (search.isEmpty ? 'POPULARITY_DESC' : 'SEARCH_MATCH')
        : sort!;

    final shouldUseSearchMatch =
        effectiveSort == 'SEARCH_MATCH' && search.isNotEmpty;
    final normalizedSort =
        shouldUseSearchMatch ? 'SEARCH_MATCH' : effectiveSort;

    return {
      'search': search.isEmpty ? null : search,
      'type': type,
      'genre': genre,
      'format': format,
      'status': status,
      'season': season,
      'seasonYear': seasonYear,
      'countryOfOrigin': countryOfOrigin,
      'sort': [normalizedSort],
      'averageScoreGreater': averageScoreGreater,
      'episodesGreater': type == 'MANGA' ? null : progressGreater,
      'chaptersGreater': type == 'MANGA' ? progressGreater : null,
      'isAdult': isAdult ?? false,
      'page': 1,
      'perPage': 25,
    };
  }

  Map<String, dynamic> toSafeVariables({required String search}) {
    final hasSearch = search.isNotEmpty;
    return {
      'search': hasSearch ? search : null,
      'type': type,
      'genre': genre,
      'sort': [hasSearch ? 'SEARCH_MATCH' : 'POPULARITY_DESC'],
      'isAdult': isAdult ?? false,
      'page': 1,
      'perPage': 25,
    };
  }
}

const List<String> _genres = [
  'Action',
  'Adventure',
  'Comedy',
  'Drama',
  'Ecchi',
  'Fantasy',
  'Horror',
  'Mahou Shoujo',
  'Mecha',
  'Music',
  'Mystery',
  'Psychological',
  'Romance',
  'Sci-Fi',
  'Slice of Life',
  'Sports',
  'Supernatural',
  'Thriller',
];
