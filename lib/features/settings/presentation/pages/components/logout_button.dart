import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../cubit/logout_cubit.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
  });

  void _showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: color),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LogoutCubit(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutComplete) {
            context.read<AuthCubit>().logout();
            _showSnackbar(context, 'You have been logged out.', Colors.green);
            Navigator.pop(context);
          } else if (state is LogoutError) {
            _showSnackbar(context, 'Error logging out.', Colors.red);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => context.read<LogoutCubit>().handleTap(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: state is LogoutInProgress && state.tapCount > 0
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      state is LogoutInitial
                          ? " L O G O U T"
                          : state is LogoutInProgress && state.tapCount == 1
                              ? " TAP 2 MORE TIMES"
                              : " TAP 1 MORE TIME",
                      key: ValueKey<int>(
                          state is LogoutInProgress ? state.tapCount : 0),
                      style: TextStyle(
                        color: state is LogoutInProgress && state.tapCount > 0
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
