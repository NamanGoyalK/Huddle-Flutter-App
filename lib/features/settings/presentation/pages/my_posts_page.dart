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
import '../../../settings/data/firebase_profile_repo.dart';
import '../../../settings/presentation/cubit/profile_cubit.dart';

class MyPostsPage extends StatelessWidget {
  MyPostsPage({super.key});

  final profileRepo = FirebaseProfileRepo();
  final postRepo = FirebasePostRepo(); // Initialize your PostRepo here.

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileCubit(profileRepo: profileRepo)),
        BlocProvider(
            create: (_) => PostCubit(postRepo: postRepo)), // New instance.
      ],
      child: const MyPostsView(),
    );
  }
}

class MyPostsView extends StatefulWidget {
  const MyPostsView({super.key});

  @override
  MyPostsViewState createState() => MyPostsViewState();
}

class MyPostsViewState extends State<MyPostsView> {
  final int todayIndex = DateTime.now().weekday - 1;
  UserProfile? userProfile;

  late final PostCubit postCubit;
  DateTime? lastRefreshTime; // Track the last refresh time

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    postCubit = context.read<PostCubit>();
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
    profileCubit.fetchUserProfile(authCubit.currentUser!.uid);
    profileCubit.stream.listen((state) {
      if (state is ProfileLoaded) {
        setState(() {
          userProfile = state.userProfile;
        });
      }
    });
  }

  void _fetchAllPosts() {
    final authCubit = context.read<AuthCubit>();
    postCubit.fetchPostByUserID(authCubit.currentUser!.uid);
  }

  void deletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this post?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                postCubit.deletePost(postId);
                _fetchAllPosts();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshPosts() async {
    final now = DateTime.now();
    if (lastRefreshTime == null ||
        now.difference(lastRefreshTime!).inSeconds >= 30) {
      setState(() {
        lastRefreshTime = now;
      });
      _fetchAllPosts();
    } else {
      final remainingTime = 30 - now.difference(lastRefreshTime!).inSeconds;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.hideCurrentSnackBar(); // Hide the current SnackBar
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
        child: Column(
          children: [
            Expanded(
              child: postsColumn(context),
            ),
            // Add BannerAdWidget here at the bottom
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Stack postsColumn(BuildContext context) {
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
              "History",
              style: TextStyle(
                // color: Colors.white,
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
        Positioned(
          top: 130,
          left: 55,
          right: -13,
          bottom: 0,
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
                      return const Center(
                        child: EmptyPostsPlaceholder(),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: allPosts.length + 1, // Add 1 for the ad
                        itemBuilder: (context, index) {
                          if (index == allPosts.length) {
                            // Show banner ad as the last item
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: BannerAdWidget(),
                            );
                          }
                          final post = allPosts[index];
                          return RoomStatusCard(
                            roomNo: post.roomNo,
                            status: post.status,
                            time: formatTime(post.scheduledTime),
                            postedTime: post.timestamp,
                            postersBlock: post.address,
                            postersName: post.userName,
                            postDescription: post.description,
                            onDelete: () => deletePost(context, post.id),
                            showDeleteButton: true,
                          );
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
        ),
        Positioned(
          top: 44,
          left: 14,
          child: CustomNavButton(
            icon: Icons.arrow_back_ios_new_outlined,
            onTap: () {
              Navigator.of(context).pop();
            },
            isRotated: false,
          ),
        ),
        const PageTitleSideWays(
          isDrawerOpen: false,
          pageTitle: 'MY POSTS',
        ),
      ],
    );
  }
}
