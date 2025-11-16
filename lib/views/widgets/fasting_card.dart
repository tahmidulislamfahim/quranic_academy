import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quranic_academy/controllers/home_controller.dart';
import 'package:quranic_academy/views/widgets/base_card.dart';

class FastingCard extends StatelessWidget {
  final HomeController ctrl;
  const FastingCard({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: "Today's Fasting",
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.grey.shade50,
        ),
        child: Obx(() {
          final text = ctrl.fasting.value.trim();

          if (text.isEmpty) {
            return Row(
              children: [
                Container(
                  width: 8,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No fasting data',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            );
          }

          return Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ),
    );
  }
}
