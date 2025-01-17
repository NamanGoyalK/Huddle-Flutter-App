import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/common/config/theme/internal_background.dart';
import 'package:huddle/common/widgets/index.dart';
import 'package:huddle/features/community_favours/presentation/pages/add_favour_bottom_sheet.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../home_room_status/presentation/cubit/day_cubit.dart';
import '../../../settings/data/firebase_profile_repo.dart';
import '../../../settings/domain/entities/user_profile.dart';
import '../../../settings/presentation/cubit/profile_cubit.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  final profileRepo = FirebaseProfileRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DayCubit()),
        BlocProvider(create: (_) => ProfileCubit(profileRepo: profileRepo)),
      ],
      child: const CommunityView(),
    );
  }
}

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  CommunityViewState createState() => CommunityViewState();
}

class CommunityViewState extends State<CommunityView> {
  final int todayIndex = DateTime.now().weekday - 1;
  UserProfile? userProfile;

  DateTime? lastRefreshTime; // Track the last refresh time

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  DateTime getDateForIndex(int index) {
    final now = DateTime.now();
    final difference = index - todayIndex;
    return now.add(Duration(days: difference));
  }

  void _loadUserProfile() {
    final profileCubit = context.read<ProfileCubit>();
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currentUser;
    if (currentUser != null) {
      profileCubit.fetchUserProfile(currentUser.uid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in.'),
        ),
      );
    }
    profileCubit.stream.listen((state) {
      if (state is ProfileLoaded) {
        setState(() {
          userProfile = state.userProfile;
        });
      }
    });
  }

  Future<void> _refreshFavours() async {
    final now = DateTime.now();
    if (lastRefreshTime == null ||
        now.difference(lastRefreshTime!).inSeconds >= 30) {
      setState(() {
        lastRefreshTime = now;
      });
    } else {
      final remainingTime = 30 - now.difference(lastRefreshTime!).inSeconds;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            'Please wait $remainingTime seconds before refreshing again.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: InternalBackground(
        child: BlocBuilder<DayCubit, DayState>(
          builder: (context, state) {
            final selectedDate = getDateForIndex(state.selectedIndex);
            final isToday = state.selectedIndex == todayIndex;
            return CommunityPageMainColumn(
                selectedDate, isToday, context, state);
          },
        ),
      ),
    );
  }

  Stack CommunityPageMainColumn(DateTime selectedDate, bool isToday,
      BuildContext context, DayState state) {
    return Stack(
      children: [
        Positioned(
          top: 40,
          right: 14,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.onSecondary,
              ],
            ).createShader(bounds),
            child: const Text(
              "Favours",
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ),
        Positioned(
          top: 120,
          right: 14,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            height: 1.0,
            width: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(0, 131, 130, 130),
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
          ),
        ),
        buildPostsList(),
        buildCustomNavButton(state),
        PageTitleSideWays(
          isDrawerOpen: state.isDrawerOpen,
          pageTitle: 'ROOM STATUS',
        ),
        buildBottomGradient(context),
        buildCreatePostButton(context),
      ],
    );
  }

  Positioned buildPostsList() {
    return Positioned(
      top: 136,
      left: 80,
      right: -6,
      bottom: 75,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
      ),
    );
  }

  Positioned buildCustomNavButton(DayState state) {
    return Positioned(
      top: 44,
      left: 14,
      child: CustomNavButton(
        icon: Icons.menu,
        onTap: () {
          context.read<DayCubit>().toggleDrawer(true);
          scaffoldKey.currentState?.openDrawer();
        },
        isRotated: state.isDrawerOpen,
      ),
    );
  }

  Positioned buildBottomGradient(BuildContext context) {
    return Positioned(
      bottom: 65,
      right: 14,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        height: 1.0,
        width: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(0, 131, 130, 130),
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
      ),
    );
  }

  Positioned buildCreatePostButton(BuildContext context) {
    return Positioned(
      bottom: 35,
      right: 20,
      child: GestureDetector(
        onTap: () {
          if (userProfile != null) {
            showAddBottomSheet(context, userProfile!);
          } else {
            showSnackBar(
              context,
              'Profile not loaded yet.',
              Colors.red,
            );
          }
        },
        child: const Text('A S K  F A V O U R'),
      ),
    );
  }
}
