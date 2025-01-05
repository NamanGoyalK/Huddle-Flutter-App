import 'package:flutter/material.dart';
import 'package:huddle/features/home_room_status/presentation/pages/components/room_card.dart';

class RoomStatusCards extends StatelessWidget {
  const RoomStatusCards({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // List of room data
    final rooms = [
      RoomData(101, 'Quiet', Icons.volume_mute_rounded, '10:00 AM'),
      RoomData(102, 'Loud', Icons.volume_up_rounded, '10:30 AM'),
      RoomData(103, 'Chill', Icons.volume_down_rounded, '11:00 AM'),
      RoomData(104, 'Quiet', Icons.volume_mute_rounded, '11:30 AM'),
      RoomData(105, 'Loud', Icons.volume_up_rounded, '12:00 PM'),
      RoomData(106, 'Chill', Icons.volume_down_rounded, '12:30 PM'),
      RoomData(107, 'Quiet', Icons.volume_mute_rounded, '1:00 PM'),
      RoomData(108, 'Loud', Icons.volume_up_rounded, '1:30 PM'),
      RoomData(109, 'Chill', Icons.volume_down_rounded, '2:00 PM'),
      RoomData(110, 'Quiet', Icons.volume_mute_rounded, '2:30 PM'),
    ];

    return Positioned(
      top: 140,
      left: 80,
      right: -4,
      bottom: 80,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: isLandscape
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns in the grid
                    crossAxisSpacing: 20.0, // Space between columns
                    mainAxisSpacing: 20.0, // Space between rows
                    childAspectRatio:
                        2.5, // Width-to-height ratio of grid items
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return RoomStatusCard(
                      roomNo: room.roomNo,
                      status: room.status,
                      icon: room.icon,
                      time: room.time,
                    );
                  },
                )
              : SingleChildScrollView(
                  child: Column(
                    children: rooms.map((room) {
                      return RoomStatusCard(
                        roomNo: room.roomNo,
                        status: room.status,
                        icon: room.icon,
                        time: room.time,
                      );
                    }).toList(),
                  ),
                ),
        ),
      ),
    );
  }
}

class RoomData {
  final int roomNo;
  final String status;
  final IconData icon;
  final String time;

  RoomData(this.roomNo, this.status, this.icon, this.time);
}
