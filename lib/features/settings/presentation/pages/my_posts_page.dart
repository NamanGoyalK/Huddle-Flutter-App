import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/home_room_status/presentation/pages/components/room_card.dart';
import 'package:huddle/features/room_status_posts/data/firebase_post_repo.dart';
import 'package:huddle/features/room_status_posts/presentation/cubit/post_cubit.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';

import '../../../../common/config/theme/internal_background.dart';
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

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    _fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InternalBackground(
        child: postsColumn(context),
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
                Theme.of(context).colorScheme.onPrimary,
              ],
            ).createShader(bounds),
            child: const Text(
              "This Week",
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
        Positioned(
          top: 136,
          left: 80,
          right: -6,
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
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: allPosts.length,
                      itemBuilder: (context, index) {
                        final post = allPosts[index];
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
                      },
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
