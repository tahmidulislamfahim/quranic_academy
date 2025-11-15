import 'package:flutter/material.dart';
import 'package:quranic_academy/controllers/home_controller.dart';
import 'package:quranic_academy/views/widgets/base_card.dart';

class ZakatCard extends StatelessWidget {
  final HomeController ctrl;
  const ZakatCard({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: "Zakat / Nisab",
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.grey.shade50,
        ),
        child: Text(
          ctrl.nisab.value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
