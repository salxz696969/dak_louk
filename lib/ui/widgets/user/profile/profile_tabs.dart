import 'package:dak_louk/ui/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileTabs extends StatelessWidget {
  final ProfileTabsEnum selectedTab;
  final ValueChanged<ProfileTabsEnum> onTabSelected;

  const ProfileTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: primary, width: 1.5),
      ),
      child: Row(
        children: ProfileTabsEnum.values.map((tab) {
          final selected = tab == selectedTab;
          return Expanded(
            child: _ProfileTabButton(
              icon: tab.icon,
              label: tab.label,
              selected: selected,
              onTap: () => onTabSelected(tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? primary : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? primary : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
