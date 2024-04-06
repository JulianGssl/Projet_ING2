import 'package:flutter/material.dart';
import 'contactpage.dart';  // Ensure the file name matches your file structure
import 'addfriendpage.dart';  // Ensure the file name matches your file structure
import 'chatlistpage.dart';


class CustomBottomAppBar extends StatelessWidget {
  final dynamic currentUser;
  final String sessionToken;
  final int activeIndex;

  const CustomBottomAppBar({
    Key? key,
    required this.currentUser,
    required this.sessionToken,
    this.activeIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent, // Sets the BottomAppBar background to be transparent
      elevation: 0, // Removes any shadow for a flat appearance
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white24, width: 0.5), // Adds a subtle top border for visual separation
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildTabItem(context, Icons.contacts, 'Contacts', 0),
              buildTabItem(context, Icons.chat, 'Chats', 1),
              buildTabItem(context, Icons.person_add, 'Add', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabItem(BuildContext context, IconData iconData, String label, int index) {
    Color color = activeIndex == index ? Colors.amber : Colors.white; // Highlights the active icon

    return InkWell(
      onTap: () {
        switch (index) {
          case 0: // Contacts
            if (activeIndex != index) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ContactPage(sessionToken: sessionToken, currentUser: currentUser)),
              );
            }
            break;
          case 1: // Chats
            if (activeIndex != index) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChatListPage(currentUser: currentUser, sessionToken: sessionToken)),
              );
            }
            break;
          case 2: // Add
            if (activeIndex != index) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddFriendPage(currentUser: currentUser, sessionToken: sessionToken)),
              );
            }
            break;
        }
      },
      splashColor: Colors.transparent, // Disables the splash effect on tap
      highlightColor: Colors.transparent, // Disables the highlight effect on tap
      overlayColor: MaterialStateProperty.all(Colors.transparent), // Ensures no overlay color on tap
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(iconData, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 12)), // The label for each icon
        ],
      ),
    );
  }
}