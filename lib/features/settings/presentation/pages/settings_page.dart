import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/settings/presentation/pages/components/about_bottom_sheet.dart';
import 'package:huddle/features/settings/presentation/pages/components/edit_profile_bottom_sheet.dart';

import '../../../../common/config/theme/internal_background.dart';
import '../../../../common/widgets/index.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import 'components/bottom_sheet_tc.dart';
import 'components/logout_button.dart';
import 'components/other_setting_buttons.dart';
import 'components/user_info_fields.dart';

class SettingsPage extends StatefulWidget {
  final String uid;

  const SettingsPage({super.key, required this.uid});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ProfileCubit profileCubit = context.read<ProfileCubit>();

  @override
  void initState() {
    super.initState();
    profileCubit.clearUserProfile().then((_) {
      profileCubit.fetchUserProfile(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InternalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 70.0,
                  top: 100,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: FullColumn(),
              ),
            ),
            Positioned(
              top: 44,
              left: 14,
              child: CustomNavButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  Navigator.pop(context);
                },
                isRotated: false,
              ),
            ),
            const PageTitleSideWays(
              isDrawerOpen: false,
              pageTitle: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}

class FullColumn extends StatelessWidget {
  const FullColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return ProfileColumn(user: state.userProfile);
            } else if (state is ProfileLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 38.0),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else {
              return Center(
                child: Text(
                  'Profile Not Found...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
              );
            }
          },
        ),
        const Spacer(),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return OtherSettings(
                settingsLabel: 'U P D A T E  P R O F I L E',
                settingsIcon: Icons.edit,
                onTap: () {
                  showEditProfileBottomSheet(context, state.userProfile);
                },
              );
            } else {
              return const SizedBox
                  .shrink(); // Placeholder for loading/error states
            }
          },
        ),
        OtherSettings(
          onTap: () {
            showThemeBottomSheet(context);
          },
          settingsLabel: 'C H A N G E  T H E M E',
          settingsIcon: Icons.color_lens_rounded,
        ),
        OtherSettings(
          settingsLabel: 'A B O U T',
          settingsIcon: Icons.info,
          onTap: () {
            showAboutBottomSheet(context);
          },
        ),
        const LogoutButton(),
      ],
    );
  }
}

class ProfileColumn extends StatelessWidget {
  const ProfileColumn({
    super.key,
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.person_rounded,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 5),
              UserInfoFields(
                text: user.gender,
                hintText: 'G E N D E R',
              ),
              const SizedBox(height: 5),
              UserInfoFields(
                text: user.address,
                hintText: 'B L O C K',
              ),
              const SizedBox(height: 5),
              UserInfoFields(
                text: user.roomNo.toString(),
                hintText: 'R O O M  N O.',
              ),
              const SizedBox(height: 5),
              UserInfoFields(
                text: user.bio,
                hintText: 'B I O',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
