import 'package:flutter/material.dart';

class Appbar extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? navigateTo;
  const Appbar({super.key, required this.title, this.icon, this.navigateTo});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          icon != null
              ? IconButton(
                  icon: Icon(icon, color: Colors.white, size: 28),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => navigateTo!),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
