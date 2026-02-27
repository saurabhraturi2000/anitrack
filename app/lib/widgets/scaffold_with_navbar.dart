import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anilist_client/utils/app_colors.dart';
import 'package:anilist_client/utils/auth_provider.dart';

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final Widget child;
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });
  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  int getCurrentIndex(String location, bool isAuthenticated) {
    if (isAuthenticated) {
      switch (location) {
        case '/home':
          return 0;
        case '/discover':
          return 1;
        case '/search':
          return 1;
        case '/profile':
          return 2;
        case '/settings':
          return 3;
        case '/appearance':
          return 3;
        default:
          return 0;
      }
    }

    switch (location) {
      case '/discover':
        return 0;
      case '/search':
        return 0;
      case '/profile':
        return 1;
      case '/settings':
        return 2;
      case '/appearance':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final colors = AppColors.of(context);
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState.maybeWhen(
      data: (state) => state == AuthState.authenticated,
      orElse: () => false,
    );

    final navItems = <_NavItem>[
      if (isAuthenticated)
        const _NavItem(
          icon: Icons.home_rounded,
          label: 'HOME',
          route: '/home',
        ),
      const _NavItem(
        icon: Icons.local_fire_department_outlined,
        label: 'DISCOVER',
        route: '/discover',
      ),
      const _NavItem(
        icon: Icons.person_outline_rounded,
        label: 'PROFILE',
        route: '/profile',
      ),
      const _NavItem(
        icon: Icons.settings_outlined,
        label: 'SETTINGS',
        route: '/settings',
      ),
    ];

    final selectedIndex = getCurrentIndex(location, isAuthenticated);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        color: colors.surface.withValues(alpha: 0.94),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final selected = index == selectedIndex;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (location != item.route) {
                          context.go(item.route);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: 54,
                        padding: EdgeInsets.symmetric(
                          horizontal: selected ? 6 : 0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected ? colors.surfaceAlt : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: selected
                            ? Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item.icon,
                                        color: colors.accent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          color: colors.accent,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  item.icon,
                                  color: colors.iconMuted,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
