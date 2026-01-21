import 'package:flutter/material.dart';
import 'package:mosque_donations/features/mosque_type/domain/mosque_type.dart';

class TypeTileMobile extends StatelessWidget {
  final MosqueType t;
  const TypeTileMobile({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 220,
                height: 140,
                child: Image.asset(
                  t.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Center(child: Icon(Icons.error, size: 48)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.nameAr,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            Text(
              t.descriptionAr,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
