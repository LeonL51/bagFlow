import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final String? profileImagePath;

  const GradientAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onProfileTap,
    this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 60,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color.fromARGB(150, 255, 255, 255),
              Color.fromARGB(0, 255, 255, 255),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          // Gesture makes avatar clickable 
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: 
              profileImagePath != null
                  ? AssetImage(profileImagePath!)
                  : null,
              // If user does not have an image, Icons.person is set as defauly
              child: profileImagePath == null
                  ? const Icon(
                      Icons.person,
                      color: Colors.black54,
                    )
                  : null,
            ),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}