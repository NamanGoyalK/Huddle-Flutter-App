import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:huddle/common/config/theme/animated_bw_background.dart';
import 'package:huddle/common/widgets/index.dart';
import 'package:huddle/features/auth/presentation/cubits/auth_cubit.dart';

import 'forgot_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.togglePages});
  final void Function()? togglePages;

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  bool passwordVisible = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                _buildPasswordTextBox(),
                _buildForgotPasswordButton(),
                _buildLoginButton(),
                _buildCreateAccountButton(),
                // const Text('or'),
                // _buildLoginWithGoogleButton('assets/icons/google.png'),
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
            DisplayText(displayText: "Welcome back!"),
            SubDisplayText(subDisplayText: "Login to continue"),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTextBox() {
    return _buildTextBox(
      controller: _emailController,
      labelText: "Email",
      hintText: "Enter email",
      icon: Icons.email_outlined,
      obscureText: false,
    );
  }

  Widget _buildPasswordTextBox() {
    return _buildTextBox(
      controller: _passwordController,
      labelText: "Password",
      hintText: "Enter Password",
      icon: Icons.key_outlined,
      obscureText: passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            passwordVisible = !passwordVisible;
          });
        },
      ),
    );
  }

  Widget _buildTextBox({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFromUser(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        labelText: labelText,
        hintText: hintText,
        obscureText: obscureText,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: SizedBox(
        width: 340,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _navigateToForgotPasswordPage,
              child: const Text("Forgot password?"),
            ),
          ],
        ),
      ),
    );
  }

  void login() {
    //prepare email and password
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    //ensure that email and password are not empty

    if (email.isNotEmpty && password.isNotEmpty) {
      //try to login
      authCubit.loginWithEmailAndPassword(email, password);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Email and password are required',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  Widget _buildLoginButton() {
    return ColoredButton(
      onPressed: () {
        login();
      },
      labelText: 'Login',
    );
  }

  Widget _buildCreateAccountButton() {
    return ColoredButton(
      onPressed: widget.togglePages,
      labelText: "Create Account",
    );
  }

  Widget _buildLoginWithGoogleButton(String googleLogo) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ColoredButton(
        onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
        labelText: " Login with Google",
        image: AssetImage(googleLogo),
      ),
    );
  }

  // Navigation methods

  void _navigateToForgotPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      ),
    );
  }
}
