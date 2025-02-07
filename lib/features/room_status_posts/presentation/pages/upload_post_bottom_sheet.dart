import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/widgets/index.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../home_room_status/presentation/cubit/day_cubit.dart';
import '../../domain/entities/post.dart';
import '../cubit/post_cubit.dart';

// Define the enum for room statuses
enum RoomStatus {
  gaming,
  studying,
  mute,
  noisy,
  neutral,
  select,
}

// Extension for RoomStatus to string conversion
extension RoomStatusExtension on RoomStatus {
  String toDisplayString() {
    switch (this) {
      case RoomStatus.gaming:
        return "Gaming";
      case RoomStatus.studying:
        return "Studying";
      case RoomStatus.mute:
        return "Mute";
      case RoomStatus.noisy:
        return "Noisy";
      case RoomStatus.neutral:
        return "Neutral";
      case RoomStatus.select:
        return "Select Status";
    }
  }
}

void showUploadBottomSheet(BuildContext context, UserProfile userProfile) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return UploadPostBlock(userProfile: userProfile);
    },
  );
}

class UploadPostBlock extends StatefulWidget {
  final UserProfile userProfile; // Add this line to accept UserProfile

  const UploadPostBlock({super.key, required this.userProfile});

  @override
  State<UploadPostBlock> createState() => _UploadPostBlockState();
}

class _UploadPostBlockState extends State<UploadPostBlock> {
  late TextEditingController descriptionController;
  RoomStatus selectedStatus = RoomStatus.select;
  final int todayIndex = DateTime.now().weekday - 1;
  AppUser? currentUser;
  String? errorMessage;
  DateTime selectedTime = DateTime.now();
  DateTime? lastPostTime;

  Duration remainingTime = Duration.zero; // Add this for countdown
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    _loadCurrentUser();
    _loadLastPostTime();
  }

  Future<void> _loadCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    setState(() {
      currentUser = authCubit.currentUser;
      if (kDebugMode) {
        print('Current User: $currentUser');
      }
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    countdownTimer?.cancel(); // Dispose timer
    super.dispose();
  }

  Future<void> _loadLastPostTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPostTimeString = prefs.getString('lastPostTime');
    if (lastPostTimeString != null) {
      setState(() {
        lastPostTime = DateTime.parse(lastPostTimeString);
        _startCountdown(); // Start countdown if time exists
      });
    }
  }

  void _startCountdown() {
    if (lastPostTime == null) return;
    final now = DateTime.now();
    final nextPostTime = lastPostTime!.add(const Duration(hours: 1));

    if (nextPostTime.isAfter(now)) {
      setState(() {
        remainingTime = nextPostTime.difference(now);
      });

      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          remainingTime = nextPostTime.difference(DateTime.now());

          if (remainingTime.isNegative) {
            timer.cancel();
            remainingTime = Duration.zero; // Reset timer when allowed
          }
        });
      });
    }
  }

  Future<void> _saveLastPostTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPostTime', time.toIso8601String());
    setState(() {
      lastPostTime = time;
      _startCountdown(); // Restart countdown on new post
    });
  }

  bool isDebugMode =
      false; // Set this to true for testing, false for production

  void _uploadPost() {
    setState(() {
      errorMessage = null;
    });

    // Check if the user's profile has valid room number and block
    if (widget.userProfile.roomNo == 0 || widget.userProfile.address.isEmpty) {
      if (kDebugMode) {
        print(
            'User Profile - Room No: ${widget.userProfile.roomNo}, Address: ${widget.userProfile.address}');
      }
      setState(() {
        errorMessage =
            'Your profile is incomplete. Please update your room number and block in the profile settings and restart the app before creating a post.';
      });
      return;
    }

    if (selectedStatus == RoomStatus.select ||
        descriptionController.text.isEmpty) {
      setState(() {
        errorMessage =
            'Please select a status and provide a brief description.';
      });
      return;
    }

    if (currentUser == null) {
      setState(() {
        errorMessage = 'User information is not available.';
      });
      return;
    }

    if (!isDebugMode &&
        lastPostTime != null &&
        DateTime.now().difference(lastPostTime!).inHours < 1) {
      setState(() {
        errorMessage = 'You can only create a post once every hour.';
      });
      return;
    }

    final dayCubit = context.read<DayCubit>();
    final selectedDayIndex = dayCubit.state.selectedIndex;

    final now = DateTime.now();
    final daysDifference = selectedDayIndex - now.weekday + 1;
    final scheduledDate = now.add(Duration(days: daysDifference));

    final scheduledTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: widget.userProfile.name, // Access user name
      address: widget.userProfile.address, // Access user address
      roomNo: widget.userProfile.roomNo, // Access user room number
      status: selectedStatus.toString(),
      timestamp: DateTime.now(),
      description: descriptionController.text,
      scheduledTime: scheduledTime,
    );

    context.read<PostCubit>().createPost(newPost);
    _saveLastPostTime(DateTime.now());

    context.read<PostCubit>().fetchAllPosts();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Post created successfully!',
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
        child: BlocConsumer<PostCubit, PostState>(
          listener: (context, state) {
            // Handle state changes if needed
          },
          builder: (context, state) {
            if (state is PostsLoading || state is PostsUploading) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHandleIndicator(),
                  const SizedBox(height: 16),
                  _buildHeader('C R E A T E   P O S T'),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                ],
              );
            } else {
              return createPostColumn(context);
            }
          },
        ),
      ),
    );
  }

  Column createPostColumn(BuildContext context) {
    bool canCreatePost = remainingTime == Duration.zero;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHandleIndicator(),
        const SizedBox(height: 16),
        _buildHeader('C R E A T E   P O S T'),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            return BlocBuilder<DayCubit, DayState>(
              builder: (context, state) {
                bool isToday = index == todayIndex;
                bool isPastDay = index < todayIndex;
                bool isSelected = state.selectedIndex == index;

                return Column(
                  children: [
                    DrawerWeekButton(
                      day: 'MTWTFSS'[index],
                      isSelected: isSelected,
                      isToday: isToday,
                      isEnabled: !isPastDay,
                      onTap: () {
                        if (!isPastDay) {
                          context.read<DayCubit>().selectDay(
                                index,
                                context.read<PostCubit>(),
                              );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          }),
        ),
        const SizedBox(height: 20),
        BlocBuilder<DayCubit, DayState>(
          builder: (context, state) {
            final selectedDayIndex = state.selectedIndex;
            bool isFutureDay = selectedDayIndex > todayIndex;

            return SizedBox(
              height: 100,
              width: 350,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime.now(),
                minimumDate: isFutureDay ? null : DateTime.now(),
                onDateTimeChanged: (DateTime value) {
                  setState(() {
                    selectedTime = value; // Update the selected time
                  });
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          context,
          'Status',
          Icons.speaker,
          selectedStatus,
          RoomStatus.values,
          (value) => DropdownMenuItem(
            value: value,
            child: Text(value.toDisplayString()),
          ),
          (value) => setState(() {
            selectedStatus = value!;
          }),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          context,
          descriptionController,
          'D E S C R I P T I O N',
          'Enter a brief description',
          Icons.notes,
          TextInputType.multiline,
        ),
        const SizedBox(height: 15),
        if (errorMessage != null) ...[
          SizedBox(
            width: 350,
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (!canCreatePost) ...[
          const Text(
            'You can create up to one post per hour.',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 10),
        ],
        ColoredButton(
          labelText: canCreatePost
              ? 'C R E A T E'
              : '${remainingTime.inMinutes}m ${remainingTime.inSeconds % 60}s',
          onPressed: canCreatePost
              ? _uploadPost
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

  Widget _buildDropdownField<T>(
    BuildContext context,
    String label,
    IconData icon,
    T value,
    List<T> items,
    DropdownMenuItem<T> Function(T value) itemBuilder,
    ValueChanged<T?> onChanged,
  ) {
    return SizedBox(
      width: 350,
      height: 50,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
        ),
        value: value,
        items: items.map(itemBuilder).toList(),
        onChanged: onChanged,
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
