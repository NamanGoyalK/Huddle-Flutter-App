import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/common/config/theme/internal_background.dart';
import 'package:huddle/common/widgets/index.dart';
import 'package:huddle/features/community/presentation/pages/components/favour_card.dart';
import 'package:huddle/features/community_favours/presentation/pages/add_favour_bottom_sheet.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../community_favours/data/firebase_favour_repo.dart';
import '../../../community_favours/presentation/cubit/favour_cubit.dart';
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
        BlocProvider(create: (_) => ProfileCubit(profileRepo: profileRepo)),
        BlocProvider(
            create: (_) => FavourCubit(favourRepo: FirebaseFavourRepo())),
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
  UserProfile? userProfile;

  DateTime? lastRefreshTime; // Track the last refresh time

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _refreshFavours();
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
      await context.read<FavourCubit>().fetchAllFavours();
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
        child: CommunityPageMainColumn(context),
      ),
    );
  }

  Stack CommunityPageMainColumn(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 35,
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
          top: 110,
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
        buildFavoursList(),
        buildCustomNavButton(),
        PageTitleSideWays(
          isDrawerOpen: false,
          pageTitle: 'COMMUNITY',
        ),
        buildBottomGradient(context),
        buildCreateFavourButton(context),
      ],
    );
  }

  Positioned buildFavoursList() {
    return Positioned(
      top: 136,
      left: 80,
      right: -6,
      bottom: 75,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: BlocBuilder<FavourCubit, FavourState>(
            builder: (context, state) {
              if (state is FavoursLoading || state is FavoursAdding) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is FavoursLoaded) {
                final allFavours = state.favours;
                if (allFavours.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshFavours,
                    child: const NoFavorsPlaceholder(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refreshFavours,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: allFavours.length,
                    itemBuilder: (context, index) {
                      final favour = allFavours[index];
                      return FavourCard(
                        index: index + 1,
                        roomNo: favour.roomNo,
                        postedTime: formatTime(favour.timestamp),
                        postersBlock: favour.address,
                        postersName: favour.userName,
                        postDescription: favour.description,
                        isUserFavor: userProfile != null &&
                            favour.userId == userProfile!.uid,
                        onDelete: () => deletePost(context, favour.id),
                      );
                    },
                  ),
                );
              } else if (state is FavoursError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshFavours,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: const [EmptyPostsPlaceholder()],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
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
                context.read<FavourCubit>().deleteFavour(postId);
                _refreshFavours();
              },
            ),
          ],
        );
      },
    );
  }

  Positioned buildCustomNavButton() {
    return Positioned(
      top: 44,
      left: 14,
      child: CustomNavButton(
        icon: Icons.arrow_back_ios_new_outlined,
        onTap: () {
          Navigator.of(context).pop();
        },
        isRotated: false,
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

  Positioned buildCreateFavourButton(BuildContext context) {
    return Positioned(
      bottom: 35,
      right: 20,
      child: GestureDetector(
        onTap: () {
          if (userProfile != null) {
            showAddBottomSheet(context, userProfile!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile not loaded yet.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Text('A S K  F A V O U R'),
      ),
    );
  }
}
