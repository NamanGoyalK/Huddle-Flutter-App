import 'package:flutter/material.dart';

import 'package:huddle/common/config/theme/animated_bw_background.dart';
import 'package:huddle/common/widgets/index.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDisplayHeading(),
                _buildEmailTextBox(),
                _buildSendEmailButton(),
                _buildLoginInsteadButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget methods
  Widget _buildDisplayHeading() {
    return const Padding(
      padding: EdgeInsets.all(18.0),
      child: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DisplayText(displayText: "Forgot Password?"),
            SubDisplayText(subDisplayText: "Don't worry!"),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTextBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFromUser(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        labelText: "Email",
        hintText: "Enter email",
        obscureText: false,
        icon: Icons.email_outlined,
      ),
    );
  }

  Widget _buildSendEmailButton() {
    return ColoredButton(
      onPressed: () {},
      labelText: 'Submit Email',
    );
  }

  Widget _buildLoginInsteadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Go back?"),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Text(
              " Login",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
