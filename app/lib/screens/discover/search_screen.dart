import 'package:anilist_client/utils/app_colors.dart';
import 'package:flutter/material.dart';

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
  String? _selectedCategory;
  String? _selectedScope;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _selectedCategory = widget.initialCategory;
    _selectedScope = widget.scope;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Search for anime & manga and more ..',
                                hintStyle: TextStyle(color: colors.iconMuted),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(Icons.grid_view_rounded, color: colors.iconMuted),
                          const SizedBox(width: 12),
                          Icon(Icons.live_tv_outlined, color: colors.iconMuted),
                        ],
                      ),
                      if (_selectedCategory != null || _selectedScope != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colors.divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_selectedCategory != null)
                                  Text(
                                    _selectedCategory!,
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                if (_selectedCategory != null && _selectedScope != null)
                                  Text(
                                    '  |  ',
                                    style: TextStyle(
                                      color: colors.iconMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                if (_selectedScope != null)
                                  Text(
                                    _selectedScope!,
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => setState(() {
                                    _selectedCategory = null;
                                    _selectedScope = null;
                                  }),
                                  child: Icon(Icons.close, size: 18, color: colors.iconMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.background,
                          colors.background.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors.textMuted,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: const Alignment(0, 0.74),
              child: SizedBox(
                width: 168,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.actionText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'FILTER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.tune, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
