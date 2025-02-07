import 'package:flutter/material.dart';

class FavourCard extends StatelessWidget {
  final int roomNo;
  final int index;
  final String postedTime;
  final String postersName;
  final String postersBlock;
  final String postDescription;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final bool isUserFavor;

  const FavourCard({
    super.key,
    required this.roomNo,
    required this.index,
    required this.postedTime,
    required this.postersName,
    required this.postersBlock,
    required this.postDescription,
    this.onDelete,
    this.showDeleteButton = false,
    this.isUserFavor = false,
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
              Text(
                ' ${index.toString()}.',
                style: const TextStyle(
                  fontSize: 18,
                ),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        capitalizeFirstLetter(
                          postersName,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        postedTime.toString(),
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
                    'Posted at $postedTime in $postersBlock block.',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Description: $postDescription',
                  ),
                  if (isUserFavor)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'F A V O U R  C O M P L E T E D  ?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
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
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}
