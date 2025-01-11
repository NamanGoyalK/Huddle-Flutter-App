import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';

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

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    setState(() {
      currentUser = authCubit.currentUser;
    });
  }

  void _uploadPost() {
    setState(() {
      errorMessage = null;
    });

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
          )),
    );
  }

  Column createPostColumn(BuildContext context) {
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
                return DrawerWeekButton(
                  day: 'MTWTFSS'[index],
                  isSelected: state.selectedIndex == index,
                  isToday: isToday,
                  onTap: () {
                    context.read<DayCubit>().selectDay(index);
                  },
                );
              },
            );
          }),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          width: 350,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: DateTime.now(),
            onDateTimeChanged: (DateTime value) {
              setState(() {
                selectedTime = value; // Update the selected time
              });
            },
          ),
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
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ColoredButton(
          labelText: 'C R E A T E',
          onPressed: _uploadPost,
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
