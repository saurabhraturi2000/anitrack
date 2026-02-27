import 'package:anilist_client/utils/auth_provider.dart';
import 'package:anilist_client/utils/app_colors.dart';
import 'package:anilist_client/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState.maybeWhen(
      data: (state) => state == AuthState.authenticated,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: colors.iconMuted),
                  ),
                  const Spacer(),
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'App Settings',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _SettingsGroup(
                items: [
                  _SettingsItemData(
                    Icons.palette_outlined,
                    'Appearance',
                    route: Routes.appearance,
                  ),
                  // _SettingsItemData(
                  //     Icons.campaign_outlined, 'Push Notifications'),
                  // _SettingsItemData(Icons.info_outline, 'About'),
                ],
              ),
              // const SizedBox(height: 14),
              // Text(
              //   'Anilist Settings',
              //   style: TextStyle(
              //     color: Theme.of(context).colorScheme.onSurface,
              //     fontSize: 17,
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // _SettingsGroup(
              //   items: [
              //     _SettingsItemData(Icons.perm_identity_rounded, 'Profile'),
              //     _SettingsItemData(Icons.tune, 'Content Preferences'),
              //     _SettingsItemData(
              //         Icons.format_list_bulleted_rounded, 'List Preferences'),
              //     _SettingsItemData(
              //         Icons.notifications_none_rounded, 'Notifications'),
              //   ],
              // ),
              const Spacer(),
              if (isAuthenticated)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/discover');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.actionText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});

  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            _SettingsRow(
              item: items[i],
              showDivider: i != items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.showDivider});

  final _SettingsItemData item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        InkWell(
          onTap: item.route == null ? null : () => context.push(item.route!),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: colors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.iconMuted, size: 24),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
          ),
      ],
    );
  }
}

class _SettingsItemData {
  const _SettingsItemData(this.icon, this.title, {this.route});

  final IconData icon;
  final String title;
  final String? route;
}
