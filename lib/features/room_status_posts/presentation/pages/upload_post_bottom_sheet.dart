import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/common/widgets/index.dart';
import 'package:huddle/features/auth/domain/entities/app_user.dart';
import 'package:huddle/features/auth/presentation/cubits/auth_cubit.dart';

// Define the enum for room statuses
enum RoomStatus {
  gamingZone,
  studyZone,
  mute,
  noisy,
  neutral,
  select,
}

// Convert enum values to display-friendly strings
String _getRoomStatusString(RoomStatus status) {
  switch (status) {
    case RoomStatus.gamingZone:
      return "Gaming Zone";
    case RoomStatus.studyZone:
      return "Study Zone";
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

void showUploadBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const UploadPostBlock();
    },
  );
}

class UploadPostBlock extends StatefulWidget {
  const UploadPostBlock({super.key});

  @override
  State<UploadPostBlock> createState() => _UploadPostBlockState();
}

class _UploadPostBlockState extends State<UploadPostBlock> {
  // Define the controllers
  late TextEditingController descriptionController;
  RoomStatus selectedStatus = RoomStatus.select;

  // Define Current User
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    descriptionController = TextEditingController();
  }

  // Get the current user
  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return _buildEditPage(context);
  }

  Padding _buildEditPage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildHandleIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildHeader(context, 'C R E A T E  P O S T'),
              ),
              const SizedBox(height: 20),
              _buildDropdownField<RoomStatus>(
                context: context,
                label: 'S T A T U S',
                icon: Icons.speaker,
                value: selectedStatus,
                items: RoomStatus.values,
                itemBuilder: (value) => DropdownMenuItem(
                  value: value,
                  child: Text(_getRoomStatusString(value)),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                context: context,
                controller: descriptionController,
                label: 'D E S C R I P T I O N',
                hint: 'Enter a brief description',
                icon: Icons.notes,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 15),
              ColoredButton(
                labelText: 'C R E A T E',
                onPressed: () {
                  if (selectedStatus != RoomStatus.select &&
                      descriptionController.text.isNotEmpty) {
                    // Handle post creation logic
                    print("Status: $selectedStatus");
                    print("Description: ${descriptionController.text}");
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select a status and provide a description.'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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

  Widget _buildHeader(BuildContext context, String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

Widget _buildDropdownField<T>({
  required BuildContext context,
  required String label,
  required IconData icon,
  required T value,
  required List<T> items,
  required DropdownMenuItem<T> Function(T value) itemBuilder,
  required ValueChanged<T?> onChanged,
}) {
  return Center(
    child: SizedBox(
      width: 350,
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
    ),
  );
}

Widget _buildTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  required TextInputType keyboardType,
}) {
  return Center(
    child: TextFromUser(
      controller: controller,
      labelText: label,
      hintText: hint,
      icon: icon,
      keyboardType: keyboardType,
      obscureText: false,
    ),
  );
}
