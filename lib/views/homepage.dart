import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quranic_academy/views/widgets/base_card.dart';
import 'package:quranic_academy/views/widgets/fasting_card.dart';
import 'package:quranic_academy/views/widgets/header_section.dart';
import 'package:quranic_academy/views/widgets/info_row.dart';
import 'package:quranic_academy/views/widgets/prayer_card.dart';
import 'package:quranic_academy/views/widgets/compass/qibla_compass.dart';
import 'package:quranic_academy/views/widgets/zakat_card.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: Text(
          'Islamic Times — Bangladesh',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: () => ctrl.loadAll(),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderSection(),
              const SizedBox(height: 18),

              // Build card widgets list (we'll layout responsively below)
              Builder(
                builder: (context) {
                  final dateCard = BaseCard(
                    title: 'Date & Hijri',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ctrl.dateReadable.isNotEmpty)
                          InfoRow("Date", ctrl.dateReadable.value),
                        if (ctrl.gregorian.isNotEmpty)
                          InfoRow("Gregorian", ctrl.gregorian.value),
                        if (ctrl.hijri.isNotEmpty)
                          InfoRow("Hijri", ctrl.hijri.value),
                      ],
                    ),
                  );

                  final qiblaCard = BaseCard(
                    title: 'Qibla Direction',
                    child: Obx(() {
                      final deg = ctrl.qiblaDegrees.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ctrl.qibla.isNotEmpty)
                            Text(
                              ctrl.qibla.value,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          const SizedBox(height: 12),
                          // Use aspect ratio so compass scales with available width
                          AspectRatio(
                            aspectRatio: 1,
                            child: QiblaCompass(qiblaDegrees: deg),
                          ),
                        ],
                      );
                    }),
                  );

                  final prohibitedCard = BaseCard(
                    title: 'Prohibited Times',
                    child: Column(
                      children: ctrl.prohibitedTimes.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: InfoRow(e.key.capitalize ?? e.key, e.value),
                        );
                      }).toList(),
                    ),
                  );

                  final widgetsList = [
                    dateCard,
                    qiblaCard,
                    prohibitedCard,
                    PrayerCard(ctrl: ctrl),
                    FastingCard(ctrl: ctrl),
                    ZakatCard(ctrl: ctrl),
                  ];

                  // Responsive layout: single column on small, two columns on wide
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxW = constraints.maxWidth;
                      final bool twoColumn = maxW >= 800;

                      if (!twoColumn) {
                        // Single column stack
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widgetsList
                              .map(
                                (w) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: w,
                                ),
                              )
                              .toList(),
                        );
                      }

                      // Two column layout: split widgets into two balanced columns
                      final left = <Widget>[];
                      final right = <Widget>[];
                      left.add(widgetsList[0]);
                      left.add(widgetsList[2]);
                      left.add(widgetsList[4]);
                      left.add(widgetsList[5]);
                      right.add(widgetsList[1]);
                      right.add(widgetsList[3]);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: left
                                  .map(
                                    (w) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                        right: 8.0,
                                      ),
                                      child: w,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: right
                                  .map(
                                    (w) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                        left: 8.0,
                                      ),
                                      child: w,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
