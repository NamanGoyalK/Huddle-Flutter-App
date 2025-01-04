import 'package:flutter/material.dart';
import 'package:huddle/common/config/theme/internal_background.dart';
import 'package:huddle/common/widgets/index.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InternalBackground(
      child: Scaffold(
        body: InternalBackground(
          child: Stack(
            children: [
              const Positioned(
                top: 24,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [],
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
                pageTitle: 'COMMUNITY',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
