import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final String title;
  final Widget child;
  const BaseCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white10 : Colors.white,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
