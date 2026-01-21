import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_donations/features/mosque_type/presentation/widgets/type_tile_desktop.dart';
import 'package:mosque_donations/features/mosque_type/presentation/widgets/type_tile_mobile.dart';

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
                child: !kIsWeb && Platform.isAndroid
                    ? TypeTileMobile(t: t)
                    : TypeTileDesktop(t: t),
              );
            },
          ),
        ),
      ),
    );
  }
}
