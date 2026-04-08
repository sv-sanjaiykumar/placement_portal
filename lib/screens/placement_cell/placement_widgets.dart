import 'package:flutter/material.dart';
import 'placement_utils.dart';

class PlacementEmptyState extends StatelessWidget {
  final String title;
  final String sub;
  final IconData icon;

  const PlacementEmptyState({
    super.key,
    required this.title,
    required this.sub,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                  color: PlacementTheme.primaryLight, shape: BoxShape.circle),
              child: Icon(icon, color: PlacementTheme.primary, size: 36),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PlacementTheme.slate900)),
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: PlacementTheme.slate500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
