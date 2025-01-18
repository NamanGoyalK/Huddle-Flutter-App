import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/home_room_status/presentation/pages/components/room_card.dart';
import 'package:huddle/features/room_status_posts/data/firebase_post_repo.dart';
import 'package:huddle/features/room_status_posts/presentation/cubit/post_cubit.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';

import '../../../../common/config/theme/internal_background.dart';
import '../../../../common/widgets/ad_mob_ads.dart';
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
  final postRepo = FirebasePostRepo(); // Initialize your PostRepo here.

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DayCubit()),
        BlocProvider(create: (_) => ProfileCubit(profileRepo: profileRepo)),
        BlocProvider(
            create: (_) => PostCubit(postRepo: postRepo)), // New instance.
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

  late final PostCubit postCubit;
  DateTime? lastRefreshTime; // Track the last refresh time

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    postCubit = BlocProvider.of<PostCubit>(context);
    _loadUserProfile();
    _fetchAllPosts();
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

  void _fetchAllPosts() {
    postCubit.fetchAllPosts();
    context.read<DayCubit>().stream.listen((state) {
      final selectedDate = getDateForIndex(state.selectedIndex);
      postCubit.filterPostsForDate(
          selectedDate); // Filter locally based on selected date
    });

    postCubit.filterPostsForAddress(userProfile?.address ?? '');
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    _fetchAllPosts();
  }

  Future<void> _refreshPosts() async {
    final now = DateTime.now();
    if (lastRefreshTime == null ||
        now.difference(lastRefreshTime!).inSeconds >= 30) {
      setState(() {
        lastRefreshTime = now;
      });
      final selectedDate =
          getDateForIndex(context.read<DayCubit>().state.selectedIndex);
      await postCubit.fetchAllPosts();
      postCubit.filterPostsForDate(selectedDate); // Filter locally on refresh
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
            return homeMainColumn(selectedDate, isToday, context, state);
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

  Stack homeMainColumn(DateTime selectedDate, bool isToday,
      BuildContext context, DayState state) {
    return Stack(
      children: [
        dateTitle(selectedDate, isToday, context),
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
          child: BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostsLoading || state is PostsUploading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is PostsLoaded) {
                final allPosts = state.posts;
                if (allPosts.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: const EmptyPostsPlaceholder(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: allPosts.length +
                        (allPosts.length ~/ 4) +
                        1, // Additional slots for ads
                    itemBuilder: (context, index) {
                      if (index % 5 == 4 ||
                          index == allPosts.length + (allPosts.length ~/ 4)) {
                        return const BannerAdWidget(); // Show an ad every 4 posts and after the last post
                      } else {
                        final postIndex = index - (index ~/ 5);
                        final post = allPosts[postIndex];
                        return RoomStatusCard(
                          roomNo: post.roomNo,
                          status: post.status,
                          // icon: Icons.abc_outlined,
                          time: formatTime(post.scheduledTime),
                          postedTime: post.timestamp,
                          postersBlock: post.address,
                          postersName: post.userName,
                          postDescription: post.description,
                        );
                      }
                    },
                  ),
                );
              } else if (state is PostsError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
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
            showUploadBottomSheet(context, userProfile!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile not loaded yet.'),
              ),
            );
          }
        },
        child: const Text('C R E A T E  P O S T'),
      ),
    );
  }
}
