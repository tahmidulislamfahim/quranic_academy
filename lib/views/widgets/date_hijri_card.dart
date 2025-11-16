import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quranic_academy/views/widgets/base_card.dart';
import 'package:quranic_academy/controllers/home_controller.dart';

class DateHijriCard extends StatelessWidget {
  final HomeController ctrl;
  const DateHijriCard({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Date & Hijri',
      child: Obx(() {
        final date = ctrl.dateReadable.value;
        final location = ctrl.locationLabel.value;
        final greg = ctrl.gregorian.value;
        final hij = ctrl.hijri.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent date + optional location under it
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date.isNotEmpty ? date : '—',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Small vertical divider and Hijri/Gregorian compact info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (greg.isNotEmpty)
                      Text(greg, style: Theme.of(context).textTheme.bodySmall),
                    if (hij.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(hij, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        );
      }),
    );
  }
}
