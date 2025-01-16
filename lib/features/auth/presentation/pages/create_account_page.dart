import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/common/config/theme/animated_bw_background.dart';
import 'package:huddle/common/widgets/index.dart';
import 'package:huddle/features/auth/presentation/cubits/auth_cubit.dart';

void main() {
  EmailOTP.config(
    appName: 'Huddle',
    otpType: OTPType.alphaNumeric,
    emailTheme: EmailTheme.v4,
  );
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key, required this.togglePages});
  final void Function()? togglePages;

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  bool _passwordVisible = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
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
                _buildNameTextBox(),
                _buildEmailTextBox(),
                _buildOtpTextBox(),
                _buildPasswordTextBox(),
                _buildCreateAccountButton(),
                const Text('or'),
                _buildLoginWithGoogleButton('assets/icons/google.png'),
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
            DisplayText(displayText: "Welcome!"),
            SubDisplayText(subDisplayText: "Create an account"),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTextBox() {
    return _buildTextBox(
      controller: _nameController,
      labelText: "Name",
      hintText: "Enter name",
      icon: Icons.person_outlined,
      obscureText: false,
    );
  }

  Widget _buildEmailTextBox() {
    return _buildTextBox(
      controller: _emailController,
      labelText: "Email",
      hintText: "Enter email",
      icon: Icons.email_outlined,
      obscureText: false,
      suffix: ButtonInsideTF(
        onPressed: _sendOTP,
        text: "Send OTP",
      ),
    );
  }

  Widget _buildOtpTextBox() {
    return _buildTextBox(
      controller: _otpController,
      labelText: "OTP",
      hintText: "Enter OTP",
      icon: Icons.password_outlined,
      obscureText: false,
      suffix: ButtonInsideTF(
        onPressed: _verifyOTP,
        text: "Verify OTP",
      ),
    );
  }

  Widget _buildPasswordTextBox() {
    return _buildTextBox(
      controller: _passwordController,
      labelText: "Password",
      hintText: "Enter Password",
      icon: Icons.key_outlined,
      obscureText: _passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
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
    Widget? suffix,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFromUser(
        controller: controller,
        keyboardType: TextInputType.text,
        labelText: labelText,
        hintText: hintText,
        obscureText: obscureText,
        icon: icon,
        suffix: suffix,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return ColoredButton(
      onPressed: _register,
      labelText: "Create Account",
    );
  }

  Widget _buildLoginWithGoogleButton(String googleLogo) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ColoredButton(
        onPressed: () {},
        labelText: "  Login with Google",
        image: AssetImage(googleLogo),
      ),
    );
  }

  Widget _buildLoginInsteadButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        GestureDetector(
          onTap: widget.togglePages,
          child: const Text(
            " Login",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Helper methods
  void _sendOTP() async {
    if (!_isEmailValid(_emailController.text)) {
      showSnackBar(context, "Enter a valid email", Colors.red);
      return;
    }

    if (await EmailOTP.sendOTP(email: _emailController.text)) {
      showSnackBar(context, "OTP has been sent", Colors.green);
    } else {
      showSnackBar(context, "Failed to send OTP", Colors.red);
    }
  }

  void _verifyOTP() {
    if (EmailOTP.getOTP() == _otpController.text) {
      showSnackBar(context, "OTP verified successfully", Colors.green);
    } else {
      showSnackBar(context, "Invalid OTP", Colors.red);
    }
  }

  void _register() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      context
          .read<AuthCubit>()
          .signupWithEmailAndPassword(name, email, password);
    } else {
      showSnackBar(context, 'Please fill in all the fields', Colors.red);
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$")
        .hasMatch(email);
  }
}
