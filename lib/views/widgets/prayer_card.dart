import 'package:flutter/material.dart';
import 'package:quranic_academy/controllers/home_controller.dart';
import 'package:quranic_academy/views/widgets/base_card.dart';

class PrayerCard extends StatelessWidget {
  final HomeController ctrl;
  const PrayerCard({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: "Prayer Times",
      child: Column(
        children: ctrl.prayerTimes.entries.map((e) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.key.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  e.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
