import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:huddle/core/config/cubit/theme_cubit.dart';
import 'package:huddle/features/auth/data/firebase_auth_repo.dart';
import 'package:huddle/features/auth/presentation/cubits/auth_cubit.dart';
import 'features/home_room_status/presentation/pages/home_page.dart';
import 'package:huddle/features/settings/data/firebase_profile_repo.dart';

import 'core/config/theme/app_colors.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/settings/presentation/cubit/profile_cubit.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of the application.

  //auth repo
  final authRepo = FirebaseAuthRepo();

  //profile repo
  final profileRepo = FirebaseProfileRepo();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Providing cubits
    return MultiBlocProvider(
      providers: [
        //Auth Cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            authRepo: authRepo,
            ProfileCubit(profileRepo: profileRepo),
          )..checkAuth(),
        ),

        //Profile Cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepo: profileRepo),
        ),

        //Theme Cubit
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appThemeMain().copyWith(
              colorScheme: appThemeMain().colorScheme.copyWith(
                    secondary: themeState.secondaryColor,
                  ),
            ),
            darkTheme: appThemeDark().copyWith(
              colorScheme: appThemeDark().colorScheme.copyWith(
                    secondary: themeState.secondaryColor,
                  ),
            ),
            themeMode: themeState.themeMode,
            home: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, authState) {
                if (authState is AuthError) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        authState.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                  );
                }
              },
              builder: (context, authState) {
                if (kDebugMode) {
                  print('Current State:$authState');
                }

                //Unauthenticated --> AuthPage
                if (authState is Authenticated) {
                  return const HomePage();
                }
                //Authenticated --> HomePage
                if (authState is UnAuthenticated) {
                  return const AuthPage();
                }
                //AuthLoading --> loading...
                else {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
