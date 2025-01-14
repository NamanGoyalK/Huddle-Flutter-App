import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void showAboutBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    isScrollControlled: false,
    builder: (BuildContext context) {
      return const AboutContent();
    },
  );
}

class AboutContent extends StatefulWidget {
  const AboutContent({super.key});

  @override
  _AboutContentState createState() => _AboutContentState();
}

class _AboutContentState extends State<AboutContent> {
  String helperText = '';
  final ScrollController _scrollController = ScrollController();

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'A B O U T',
                style:
                    Theme.of(context).textTheme.titleLarge ?? const TextStyle(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Welcome to Huddle!',
                  style: (Theme.of(context).textTheme.headlineSmall ??
                          const TextStyle())
                      .copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Huddle is designed to revolutionize your room-sharing experience. '
              'Whether you need a quiet study environment or a vibrant space to socialize, Huddle is here to connect you with the perfect room and people.',
              style:
                  (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                      .copyWith(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Text(
              'Key Features:',
              style: (Theme.of(context).textTheme.headlineSmall ??
                      const TextStyle())
                  .copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            buildFeatureItem(context, 'Real-time Room Status:',
                'Get instant updates on room availability and status to find the perfect match for your needs.'),
            buildFeatureItem(context, 'Notifications:',
                'Receive timely notifications to stay updated about room changes and availability.'),
            buildFeatureItem(context, 'Enhanced Coordination:',
                'Coordinate seamlessly with roommates for a more organized and enjoyable shared living experience.'),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Discover the joy of tailored spaces with Huddle. Your shared living, smarter and more fun!',
                style:
                    (Theme.of(context).textTheme.bodyLarge ?? const TextStyle())
                        .copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      const url = 'https://www.linkedin.com/in/naman-goyal-dev';
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Text(
                      'Developed by Naman Goyal.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          const url =
                              'https://www.linkedin.com/in/naman-goyal-dev';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: Icon(FontAwesomeIcons.linkedin),
                      ),
                      IconButton(
                        onPressed: () async {
                          const url = 'https://github.com/NamanGoyalK';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: Icon(FontAwesomeIcons.squareGithub),
                      ),
                      IconButton(
                        onPressed: () async {
                          const email = 'namangoyaldev@gmail.com';
                          await Clipboard.setData(ClipboardData(text: email));
                          setState(() {
                            helperText =
                                'You can contact me at namangoyaldev@gmail.com. The email address has been copied to your clipboard.';
                          });
                          _scrollToEnd();
                        },
                        icon: Icon(FontAwesomeIcons.squareGooglePlus),
                      ),
                    ],
                  ),
                  if (helperText.isNotEmpty) // Conditionally show the text
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            helperText,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.green,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureItem(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title ',
              style:
                  (Theme.of(context).textTheme.bodyLarge ?? const TextStyle())
                      .copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge ?? const TextStyle(),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
