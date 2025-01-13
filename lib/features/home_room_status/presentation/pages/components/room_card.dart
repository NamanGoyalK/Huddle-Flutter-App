import 'package:flutter/material.dart';
import 'package:huddle/common/widgets/index.dart';

class RoomStatusCard extends StatelessWidget {
  final int roomNo;
  final String status;
  final String time;
  final DateTime postedTime;
  final String postersName;
  final String postersBlock;
  final String postDescription;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const RoomStatusCard({
    super.key,
    required this.roomNo,
    required this.status,
    required this.time,
    required this.postedTime,
    required this.postersName,
    required this.postersBlock,
    required this.postDescription,
    this.onDelete,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: ExpansionTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForStatus(status),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Room ${roomNo.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(capitalizeFirstLetter(
                          status.split('.')[1].toString())),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posted by $postersName at ${formatTime(postedTime)} for $postersBlock block.',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Description: $postDescription',
                  ),
                  if (showDeleteButton && onDelete != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'D E L E T E  P O S T',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        onTap: onDelete,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'RoomStatus.gaming':
        return Icons.gamepad_outlined;
      case 'RoomStatus.studying':
        return Icons.menu_book_outlined;
      case 'RoomStatus.mute':
        return Icons.volume_off_outlined;
      case 'RoomStatus.noisy':
        return Icons.speaker_outlined;
      case 'RoomStatus.neutral':
        return Icons.speaker_notes_outlined;
      case 'RoomStatus.select':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}
