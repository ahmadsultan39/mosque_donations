import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../mosque_type/domain/mosque_types.dart';
import '../bloc/mosque_type_bloc.dart';
import '../bloc/mosque_type_event.dart';

class TypeSelectionPage extends StatelessWidget {
  const TypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MosqueTypes.all;
    return Scaffold(
      appBar: AppBar(title: const Text('اختر نوع المسجد')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final t = items[index];
              return InkWell(
                onTap: () {
                  context.read<MosqueTypeBloc>().add(SelectMosqueType(t));
                  Navigator.of(context).pushNamed('/form', arguments: t);
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 220,
                            height: 140,
                            child: Image.asset(
                              t.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Center(child: Icon(Icons.error, size: 48)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.nameAr,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.descriptionAr,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
