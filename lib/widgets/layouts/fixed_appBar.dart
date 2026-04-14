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
      // Shadow control 
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      forceMaterialTransparency: true,
      // Built-in go back button 
      automaticallyImplyLeading: true,
      toolbarHeight: 90,
      flexibleSpace: IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.45, 1.0],
              colors: [
                Color(0xF2FFFFFF),
                Color(0x99FFFFFF),
                Color(0x00FFFFFF),
              ],
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            // Profile Image 
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              backgroundImage:
                  profileImagePath != null ? AssetImage(profileImagePath!) : null,
              child: profileImagePath == null
                  ? const Icon(
                      Icons.person,
                      color: Colors.black54,
                    )
                  : null,
            ),
          ),
          // Screen Title
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          // Menu Icon 
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
  Size get preferredSize => const Size.fromHeight(90);
}