import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/home_room_status/presentation/pages/components/room_status_cards.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';
// import 'package:huddle/features/settings/domain/repos/profile_repo.dart';

import '../../../../common/config/theme/internal_background.dart';
import '../../../../common/widgets/index.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../community/presentation/pages/community_page.dart';
import '../../../room_status_posts/presentation/pages/upload_post_bottom_sheet.dart';
import '../../../settings/data/firebase_profile_repo.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../cubit/day_cubit.dart';
import '../../../settings/presentation/cubit/profile_cubit.dart';

part 'components/custom_drawer.dart';
part 'components/date_title.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final profileRepo = FirebaseProfileRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DayCubit()),
        BlocProvider(
          create: (_) => ProfileCubit(profileRepo: profileRepo),
        ), // Add ProfileCubit here
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final int todayIndex = DateTime.now().weekday - 1;
  UserProfile? userProfile;

  DateTime getDateForIndex(int index) {
    DateTime now = DateTime.now();
    int difference = index - (now.weekday - 1);
    return now.add(Duration(days: difference));
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final profileCubit = context.read<ProfileCubit>();
    final authCubit = context.read<AuthCubit>();
    profileCubit.fetchUserProfile(authCubit.currentUser!.uid);
    profileCubit.stream.listen((state) {
      if (state is ProfileLoaded) {
        setState(() {
          userProfile = state.userProfile;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InternalBackground(
        child: BlocBuilder<DayCubit, DayState>(
          builder: (context, state) {
            DateTime selectedDate = getDateForIndex(state.selectedIndex);
            bool isToday = state.selectedIndex == todayIndex;
            return Stack(
              children: [
                dateTitle(selectedDate, isToday, context),
                const RoomStatusCards(),
                Positioned(
                  top: 44,
                  left: 14,
                  child: CustomNavButton(
                    icon: Icons.menu,
                    onTap: () {
                      context.read<DayCubit>().toggleDrawer(true);
                      Scaffold.of(context).openDrawer();
                    },
                    isRotated: state.isDrawerOpen,
                  ),
                ),
                PageTitleSideWays(
                  isDrawerOpen: state.isDrawerOpen,
                  pageTitle: 'ROOM STATUS',
                ),
                Positioned(
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
                ),
                Positioned(
                  bottom: 35,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (userProfile != null) {
                        showUploadBottomSheet(context, userProfile!);
                      } else {
                        // Handle the case where the user profile is not yet loaded
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile not loaded yet.'),
                          ),
                        );
                      }
                    },
                    child: const Text('C R E A T E  P O S T'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      drawerScrimColor: const Color.fromARGB(10, 0, 0, 0),
      onDrawerChanged: (isOpen) {
        context.read<DayCubit>().toggleDrawer(isOpen);
      },
      drawer: const CustomDrawer(),
    );
  }
}
