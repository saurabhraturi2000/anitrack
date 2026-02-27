import 'package:anitrack/screens/auth/login_screen.dart';
import 'package:anitrack/utils/app_colors.dart';
import 'package:anitrack/utils/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final authState = ref.watch(authStateProvider);
    final user = ref.watch(userProvider);
    return Scaffold(
      body: authState.when(
        data: (data) {
          return data == AuthState.authenticated
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(user!.bannerImage!),
                              fit: BoxFit.cover,
                            ), // Change to your preferred color
                          ),
                        ),
                        // User Avatar
                        Positioned(
                          bottom: -40,
                          left: 20,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(user.avatarUrl),
                            // backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50), // Spacing below avatar
                    // User Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    //follow stats
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Followers',
                                  style: TextStyle(color: colors.textMuted),
                                ),
                                Text(
                                  "100",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: colors.divider,
                            thickness: 0.5,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Following',
                                  style: TextStyle(color: colors.textMuted),
                                ),
                                Text(
                                  "100",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // stats
                    Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ANIME',
                                  style: TextStyle(color: colors.textMuted),
                                ),
                                Text(
                                  "100",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'MANGA',
                                  style: TextStyle(color: colors.textMuted),
                                ),
                                Text(
                                  "200",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'FAVOURITES',
                                  style: TextStyle(color: colors.textMuted),
                                ),
                                Text(
                                  "200",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    //tabs(bio,overview,activity,reviews)
                  ],
                )
              : LoginScreen();
        },
        error: (error, stack) => Center(
          child: Text(
            error.toString(),
          ),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

