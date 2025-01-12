import 'package:flutter/material.dart';

class RoomStatusCard extends StatelessWidget {
  final int roomNo;
  final String status;
  final String time;

  const RoomStatusCard({
    required this.roomNo,
    required this.status,
    required this.time,
    super.key,
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
                  Text('Status: ${capitalizeFirstLetter(status)}'),
                  // Add more details here
                  const Text('Additional detail 1'),
                  const Text('Additional detail 2'),
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
