import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/rendering.dart';

import '../../../mosque_type/domain/mosque_type.dart';
import '../../domain/form_models.dart';
import '../bloc/pricing_bloc.dart';
import '../bloc/pricing_event.dart';
import '../bloc/pricing_state.dart';

class PricingFormPage extends StatefulWidget {
  final MosqueType type;

  const PricingFormPage({super.key, required this.type});

  @override
  State<PricingFormPage> createState() => _PricingFormPageState();
}

class _PricingFormPageState extends State<PricingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _captureKey = GlobalKey();

  String _fileSafeName(String? raw, String ext) {
    final base = (raw ?? '').trim();
    final safeBase = base.isEmpty
        ? 'mosque_pricing'
        : base.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return '$safeBase.$ext';
  }

  Future<Uint8List?> _captureImageBytes() async {
    try {
      final renderObject = _captureKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        final image = await renderObject.toImage(pixelRatio: 3);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveAsImage() async {
    final values = context.read<PricingBloc>().state.values;
    final name = _fileSafeName(values['mosque_name'] as String?, 'png');
    final bytes = await _captureImageBytes();
    if (bytes == null) return;
    final file = XFile.fromData(bytes, name: name, mimeType: 'image/png');
    final location = await getSaveLocation(
      suggestedName: name,
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PNG', extensions: ['png']),
      ],
    );
    if (location == null) return;
    await file.saveTo(location.path);
  }

  Future<void> _saveAsPdf() async {
    final values = context.read<PricingBloc>().state.values;
    final name = _fileSafeName(values['mosque_name'] as String?, 'pdf');
    final bytes = await _captureImageBytes();
    if (bytes == null) return;
    final doc = pw.Document();
    final image = pw.MemoryImage(bytes);
    doc.addPage(pw.Page(build: (context) => pw.Center(child: pw.Image(image))));
    final pdfBytes = await doc.save();
    final file = XFile.fromData(
      pdfBytes,
      name: name,
      mimeType: 'application/pdf',
    );
    final location = await getSaveLocation(
      suggestedName: name,
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );
    if (location == null) return;
    await file.saveTo(location.path);
  }

  @override
  void initState() {
    super.initState();
    context.read<PricingBloc>().add(InitializePricing(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('نموذج ${widget.type.nameAr}')),
      body: BlocBuilder<PricingBloc, PricingState>(
        builder: (context, state) {
          final schema = state.schema;
          if (schema == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RepaintBoundary(
                      key: _captureKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    ...schema.fields.map(
                                      (f) => _buildField(
                                        context,
                                        state,
                                        f,
                                        state.values[f.id],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            context.read<PricingBloc>().add(
                                              SubmitPricing(widget.type),
                                            );
                                          }
                                        },
                                        child: const Text('احسب الكلفة'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state.submitted && state.totalPrice != null)
                            Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Builder(
                                  builder: (context) {
                                    final formatter =
                                        NumberFormat.decimalPattern('ar');
                                    final formatted = formatter.format(
                                      state.totalPrice!.round(),
                                    );
                                    return Text(
                                      'الكلفة التقديرية: $formatted',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (state.submitted && state.totalPrice != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _saveAsImage,
                            icon: const Icon(Icons.image),
                            label: const Text('حفظ كصورة'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _saveAsPdf,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('حفظ PDF'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isVisible(FormFieldSpec spec, Map<String, dynamic> values) {
    if (spec.dependsOn == null) return true;
    final depVal = values[spec.dependsOn];
    if (spec.dependsOnNotEmpty) {
      return depVal != null && depVal.toString().isNotEmpty;
    }
    if (spec.dependsOnEquals != null) {
      return depVal == spec.dependsOnEquals;
    }
    return depVal != null;
  }

  Widget _buildField(
    BuildContext context,
    PricingState state,
    FormFieldSpec spec,
    dynamic value,
  ) {
    final visible = _isVisible(spec, state.values);
    if (!visible) {
      return const SizedBox.shrink();
    }
    switch (spec.type) {
      case FieldType.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            initialValue: value?.toString() ?? '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: spec.required ? '${spec.labelAr} *' : spec.labelAr,
              helperText: spec.min != null
                  ? (spec.max != null
                        ? 'من ${spec.min} إلى ${spec.max}'
                        : 'أكبر من ${spec.min}')
                  : (spec.max != null ? 'حتى ${spec.max}' : null),
              border: const OutlineInputBorder(),
            ),
            validator: (v) {
              final val = double.tryParse(v ?? '');
              if (spec.required && val == null) return 'حقل مطلوب';
              if (val != null) {
                if (spec.min != null && val < spec.min!) {
                  return 'القيمة أقل من الحد الأدنى';
                }
                if (spec.max != null && val > spec.max!) {
                  return 'القيمة أكبر من الحد الأعلى';
                }
              }
              return null;
            },
            onChanged: (v) =>
                context.read<PricingBloc>().add(UpdateField(spec.id, v)),
          ),
        );
      case FieldType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            initialValue: value?.toString() ?? '',
            decoration: InputDecoration(
              labelText: spec.required ? '${spec.labelAr} *' : spec.labelAr,
              border: const OutlineInputBorder(),
              labelStyle: TextStyle(
                overflow: TextOverflow.visible,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            validator: (v) => (spec.required && (v == null || v.trim().isEmpty))
                ? 'حقل مطلوب'
                : null,
            onChanged: (v) =>
                context.read<PricingBloc>().add(UpdateField(spec.id, v)),
          ),
        );
      case FieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: FormField<String>(
            initialValue: value is String ? value : null,
            validator: (v) => (spec.required && (v == null || v.isEmpty))
                ? 'حقل مطلوب'
                : null,
            builder: (field) {
              final opts = spec.options ?? [];
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: spec.labelAr,
                  // helperText: 'اختر قيمة',
                  errorText: field.errorText,
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(
                    overflow: TextOverflow.visible,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: opts
                      .map(
                        (o) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: o,
                              groupValue: field.value,
                              onChanged: (v) {
                                field.didChange(v);
                                context.read<PricingBloc>().add(
                                  UpdateField(spec.id, v),
                                );
                              },
                            ),
                            Text(
                              o == "محافظة"
                                  ? "$o (دمشق ومراكز المحافظات الأخرى)"
                                  : o,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        );
      case FieldType.boolean:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: FormField<bool>(
            initialValue: value == true
                ? true
                : (value == false ? false : null),
            validator: (v) => (spec.required && v == null) ? 'حقل مطلوب' : null,
            builder: (field) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: spec.required ? '${spec.labelAr} *' : spec.labelAr,
                  // helperText: 'اختر قيمة',
                  errorText: field.errorText,
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(
                    overflow: TextOverflow.visible,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                child: Wrap(
                  spacing: 32,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: field.value,
                          onChanged: (v) {
                            field.didChange(v);
                            context.read<PricingBloc>().add(
                              UpdateField(spec.id, true),
                            );
                          },
                        ),
                        const Text('نعم'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: field.value,
                          onChanged: (v) {
                            field.didChange(v);
                            context.read<PricingBloc>().add(
                              UpdateField(spec.id, false),
                            );
                          },
                        ),
                        const Text('لا'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
    }
  }
}
