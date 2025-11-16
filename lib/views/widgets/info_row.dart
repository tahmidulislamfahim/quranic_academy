import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String t;
  final String v;
  const InfoRow(this.t, this.v, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Text(
            t,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: Text(
            v,
            textAlign: TextAlign.right,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
