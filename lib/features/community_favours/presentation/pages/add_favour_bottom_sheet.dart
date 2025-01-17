import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/widgets/index.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../domain/entities/favour.dart';
import '../cubit/favour_cubit.dart';

void showAddBottomSheet(BuildContext context, UserProfile userProfile) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddFavourBlock(userProfile: userProfile);
    },
  );
}

class AddFavourBlock extends StatefulWidget {
  final UserProfile userProfile;

  const AddFavourBlock({super.key, required this.userProfile});

  @override
  State<AddFavourBlock> createState() => _AddFavourBlockState();
}

class _AddFavourBlockState extends State<AddFavourBlock> {
  late TextEditingController descriptionController;
  AppUser? currentUser;
  String? errorMessage;
  DateTime selectedTime = DateTime.now();
  DateTime? lastFavourTime;
  Duration remainingTime = Duration.zero; // Add this for countdown
  Timer? countdownTimer;
  bool isDebugMode =
      false; // Set this to true for testing, false for production

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    _loadCurrentUser();
    _loadLastFavourTime();
  }

  Future<void> _loadCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    setState(() {
      currentUser = authCubit.currentUser;
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    countdownTimer?.cancel(); // Dispose timer
    super.dispose();
  }

  Future<void> _loadLastFavourTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFavourTimeString = prefs.getString('lastFavourTime');
    if (lastFavourTimeString != null) {
      setState(() {
        lastFavourTime = DateTime.parse(lastFavourTimeString);
        _startCountdown(); // Start countdown if time exists
      });
    }
  }

  void _startCountdown() {
    if (lastFavourTime == null) return;
    final now = DateTime.now();
    final nextFavourTime = lastFavourTime!.add(const Duration(hours: 1));

    if (nextFavourTime.isAfter(now)) {
      setState(() {
        remainingTime = nextFavourTime.difference(now);
      });

      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          remainingTime = nextFavourTime.difference(DateTime.now());

          if (remainingTime.isNegative) {
            timer.cancel();
            remainingTime = Duration.zero; // Reset timer when allowed
          }
        });
      });
    }
  }

  Future<void> _saveLastFavourTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFavourTime', time.toIso8601String());
    setState(() {
      lastFavourTime = time;
      _startCountdown(); // Restart countdown on new favour
    });
  }

  void _uploadFavour() {
    setState(() {
      errorMessage = null;
    });

    // Check if the user's profile has valid room number and block
    if (widget.userProfile.roomNo == 0 || widget.userProfile.address.isEmpty) {
      setState(() {
        errorMessage =
            'Your profile is incomplete. Please update your room number and block in the profile settings before creating a favour.';
      });
      return;
    }

    if (currentUser == null) {
      setState(() {
        errorMessage = 'User information is not available.';
      });
      return;
    }

    if (!isDebugMode) {
      if (lastFavourTime != null &&
          DateTime.now().difference(lastFavourTime!).inHours < 1) {
        setState(() {
          errorMessage = 'You can only create a favour once every hour.';
        });
        return;
      }
    }

    final newFavour = Favour(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: widget.userProfile.name,
      address: widget.userProfile.address,
      roomNo: widget.userProfile.roomNo,
      timestamp: DateTime.now(),
      description: descriptionController.text,
      isComplete: false,
    );

    context.read<FavourCubit>().createFavour(newFavour);
    _saveLastFavourTime(DateTime.now());
    context.read<FavourCubit>().fetchAllFavours();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Favour created successfully!',
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<FavourCubit, FavourState>(
          listener: (context, state) {
            // Handle state changes if needed
          },
          builder: (context, state) {
            if (state is FavoursLoading || state is FavoursAdding) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHandleIndicator(),
                  const SizedBox(height: 16),
                  _buildHeader('A D D  F A V O U R'),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                ],
              );
            } else {
              return createFavourColumn(context);
            }
          },
        ),
      ),
    );
  }

  Column createFavourColumn(BuildContext context) {
    bool canCreateFavour = remainingTime == Duration.zero;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHandleIndicator(),
        const SizedBox(height: 16),
        _buildHeader('A D D  F A V O U R'),
        const SizedBox(height: 20),
        _buildTextField(
          context,
          descriptionController,
          'E N T E R  F A V O U R',
          'Enter a brief description of the favour',
          Icons.notes,
          TextInputType.multiline,
        ),
        const SizedBox(height: 15),
        if (errorMessage != null) ...[
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (!canCreateFavour) ...[
          const Text(
            'You can add up to one favour per hour.',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 10),
        ],
        ColoredButton(
          labelText: canCreateFavour
              ? 'A S K'
              : '${remainingTime.inMinutes}m ${remainingTime.inSeconds % 60}s',
          onPressed: canCreateFavour
              ? _uploadFavour
              : () {
                  setState(() {
                    errorMessage = 'Please try later.';
                  });
                }, // Disable button if not allowed
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHandleIndicator() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    TextInputType keyboardType,
  ) {
    return TextFromUser(
      controller: controller,
      labelText: label,
      hintText: hint,
      icon: icon,
      keyboardType: keyboardType,
      obscureText: false,
    );
  }
}
