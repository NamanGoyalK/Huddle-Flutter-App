// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/widgets/index.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../domain/entities/post.dart';
import '../cubit/post_cubit.dart';

// Define the enum for room statuses
enum RoomStatus {
  gamingZone,
  studyZone,
  mute,
  noisy,
  neutral,
  select,
}

// Extension for RoomStatus to string conversion
extension RoomStatusExtension on RoomStatus {
  String toDisplayString() {
    switch (this) {
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
  late TextEditingController descriptionController;
  RoomStatus selectedStatus = RoomStatus.select;
  AppUser? currentUser;

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
    if (selectedStatus == RoomStatus.select ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select a status and provide a brief description.'),
        ),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information is not available.'),
        ),
      );
      return;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      address: '',
      roomNo: 0,
      status: selectedStatus.toString(),
      timestamp: DateTime.now(),
      description: descriptionController.text,
    );

    context.read<PostCubit>().createPost(newPost);

    // Close the bottom sheet
    Navigator.of(context).pop();

    // Show the success message after popping
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully!'),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHandleIndicator(),
            const SizedBox(height: 16),
            _buildHeader('C R E A T E  P O S T'),
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
            ColoredButton(
              labelText: 'Create',
              onPressed: _uploadPost,
            ),
            const SizedBox(height: 20),
          ],
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
