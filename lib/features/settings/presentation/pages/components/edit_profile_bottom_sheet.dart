import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/common/widgets/index.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';
import 'package:huddle/features/settings/presentation/cubit/profile_cubit.dart';

enum Gender {
  male,
  female,
  select,
}

enum Block {
  select,
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
  I,
  J,
  K,
  L,
  M,
  N,
  O,
  P,
  Q,
  R,
  S,
  T
}

void showEditProfileBottomSheet(BuildContext context, UserProfile user) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return EditProfileContent(user: user);
    },
  ).then((_) {
    if (context.mounted) {
      // Refresh the profile data in the parent view
      context.read<ProfileCubit>().fetchUserProfile(user.uid);
    }
  });
}

class EditProfileContent extends StatefulWidget {
  final UserProfile user;

  const EditProfileContent({super.key, required this.user});

  @override
  EditProfileContentState createState() => EditProfileContentState();
}

class EditProfileContentState extends State<EditProfileContent> {
  late TextEditingController bioController;
  late TextEditingController roomNoController;
  Gender? selectedGender;
  Block? selectedBlock;

  @override
  void initState() {
    super.initState();

    // Initialize text controllers with existing user data
    bioController = TextEditingController(text: widget.user.bio);
    roomNoController =
        TextEditingController(text: widget.user.roomNo.toString());

    // Map user gender and block to enums
    selectedGender = _mapGender(widget.user.gender);
    selectedBlock = _mapBlock(widget.user.address);
  }

  @override
  void dispose() {
    bioController.dispose();
    roomNoController.dispose();
    super.dispose();
  }

  Gender _mapGender(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.select;
    }
  }

  Block _mapBlock(String? block) {
    return Block.values.firstWhere(
      (b) => b.name.toLowerCase() == block?.toLowerCase(),
      orElse: () => Block.select,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Call the custom method that builds the UI.
    return _buildEditPage(context);
  }

  Padding _buildEditPage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildHandleIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildHeader(context, 'E D I T  P R O F I L E'),
            ),
            const SizedBox(height: 20),
            _buildDropdownField<Gender>(
              context: context,
              label: 'G E N D E R',
              icon: Icons.man_2_rounded,
              value: selectedGender,
              items: Gender.values,
              itemBuilder: (value) => DropdownMenuItem(
                value: value,
                child: Text(_getGenderLabel(value)),
              ),
              onChanged: (value) => setState(() => selectedGender = value),
            ),
            const SizedBox(height: 20),
            _buildDropdownField<Block>(
              context: context,
              label: 'B L O C K',
              icon: Icons.apartment_outlined,
              value: selectedBlock,
              items: Block.values,
              itemBuilder: (value) => DropdownMenuItem(
                value: value,
                child: Text(_getBlockLabel(value)),
              ),
              onChanged: (value) => setState(() => selectedBlock = value),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context: context,
              controller: roomNoController,
              label: 'R O O M  N O.',
              hint: 'Enter room number',
              icon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context: context,
              controller: bioController,
              label: 'B I O',
              hint: 'Enter bio',
              icon: Icons.book,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 15),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ColoredButton(
                  labelText: 'U P D A T E',
                  onPressed: () async {
                    final profileCubit = context.read<ProfileCubit>();

                    await profileCubit.updateProfile(
                      uid: widget.user.uid,
                      newBio: bioController.text,
                      newRoomNo: int.tryParse(roomNoController.text),
                      newGender: selectedGender != Gender.select
                          ? _getGenderLabel(selectedGender!)
                          : null,
                      newAddress: selectedBlock != Block.select
                          ? _getBlockLabel(selectedBlock!)
                          : null,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

Widget _buildDropdownField<T>({
  required BuildContext context,
  required String label,
  required IconData icon,
  required T? value,
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

String _getGenderLabel(Gender gender) {
  switch (gender) {
    case Gender.male:
      return 'Male';
    case Gender.female:
      return 'Female';
    case Gender.select:
      // default:
      return 'Select Gender';
  }
}

String _getBlockLabel(Block block) {
  return block == Block.select ? 'Select Block' : block.name;
}
