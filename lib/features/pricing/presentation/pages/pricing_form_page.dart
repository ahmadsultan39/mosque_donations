import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart' as pdf;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:io' show Platform;
// import 'dart:math' as math;
import 'package:media_store_plus/media_store_plus.dart';

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

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (img) => completer.complete(img));
    return completer.future;
  }

  Future<Uint8List?> _composeWithHeader(Uint8List bodyPng) async {
    try {
      final headerData = await rootBundle.load(widget.type.imageUrl);
      final headerBytes = headerData.buffer.asUint8List();
      final bodyImg = await _decodeImage(bodyPng);
      final headerImg = await _decodeImage(headerBytes);
      final targetWidth = bodyImg.width;
      final headerScale = targetWidth / headerImg.width;
      final headerHeight = (headerImg.height * headerScale).round();
      final totalHeight = headerHeight + bodyImg.height;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();
      // white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, targetWidth.toDouble(), totalHeight.toDouble()),
        paint..color = const Color(0xFFFFFFFF),
      );
      // draw header scaled to width
      canvas.drawImageRect(
        headerImg,
        Rect.fromLTWH(
          0,
          0,
          headerImg.width.toDouble(),
          headerImg.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, targetWidth.toDouble(), headerHeight.toDouble()),
        Paint(),
      );
      // draw body below header
      canvas.drawImage(bodyImg, Offset(0, headerHeight.toDouble()), Paint());
      final picture = recorder.endRecording();
      final merged = await picture.toImage(targetWidth, totalHeight);
      final bytes = await merged.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getSavePathWithFallback(
    String name,
    XTypeGroup typeGroup,
  ) async {
    try {
      final location = await getSaveLocation(
        suggestedName: name,
        acceptedTypeGroups: [typeGroup],
      );
      if (location != null) return location.path;
    } catch (_) {}
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (dirs != null && dirs.isNotEmpty) {
          return '${dirs.first.path}/$name';
        }
      } catch (_) {}
    }
    if (!kIsWeb) {
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null) return '${ext.path}/$name';
      } catch (_) {}
      try {
        final dir = await getApplicationDocumentsDirectory();
        return '${dir.path}/$name';
      } catch (_) {}
    }
    return null;
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
    final name = _fileSafeName("${values['mosque_name'] as String?}_${DateTime.now().toString()}", 'png');
    final bytes = await _captureImageBytes();
    if (bytes == null) return;
    try {
      final composed = await _composeWithHeader(bytes) ?? bytes;
      if (!kIsWeb && Platform.isAndroid) {
        try {
          await MediaStore.ensureInitialized();
          MediaStore.appFolder = "MosqueDonations";
          final tmpDir = await getTemporaryDirectory();
          final tmpPath = '${tmpDir.path}/$name';
          final temp = XFile.fromData(
            composed,
            name: name,
            mimeType: 'image/png',
          );
          await temp.saveTo(tmpPath);
          final mediaStore = MediaStore();
          final saved = await mediaStore.saveFile(
            tempFilePath: tmpPath,
            dirType: DirType.download,
            dirName: DirName.download,
          );
          if (saved != null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ الصورة في مجلد التنزيلات')),
            );
            return;
          }
        } catch (_) {}
      }
      final file = XFile.fromData(composed, name: name, mimeType: 'image/png');
      final path = await _getSavePathWithFallback(
        name,
        const XTypeGroup(label: 'PNG', extensions: ['png']),
      );
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر تحديد مسار الحفظ')));
        return;
      }
      await file.saveTo(path);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم حفظ الصورة في: $path')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل حفظ الصورة: $e')));
    }
  }

  // Future<void> _saveAsPdf() async {
  //   final values = context.read<PricingBloc>().state.values;
  //   final name = _fileSafeName(values['mosque_name'] as String?, 'pdf');
  //   final bytes = await _captureImageBytes();
  //   if (bytes == null) return;
  //   try {
  //     final doc = pw.Document();
  //     final bodyUi = await _decodeImage(bytes);
  //     Uint8List? headerBytes;
  //     ui.Image? headerUi;
  //     try {
  //       final headerData = await rootBundle.load(widget.type.imageUrl);
  //       headerBytes = headerData.buffer.asUint8List();
  //       headerUi = await _decodeImage(headerBytes);
  //     } catch (e) {
  //       headerBytes = null;
  //       headerUi = null;
  //       if (mounted) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text('فشل تحميل صورة النوع: $e')));
  //       }
  //     }
  //     final pageWidthPts = pdf.PdfPageFormat.a4.width;
  //     final pageHeightPts = pdf.PdfPageFormat.a4.height;
  //     final marginPts = 20.0;
  //     final contentWidthPts = pageWidthPts - marginPts * 2;
  //     final contentHeightPts = pageHeightPts - marginPts * 2;
  //     double headerImageHeightPts = 0;
  //     const spacingPts = 12.0;
  //     if (headerUi != null) {
  //       headerImageHeightPts =
  //           (headerUi.height / headerUi.width) * contentWidthPts;
  //       if (headerImageHeightPts + spacingPts > contentHeightPts) {
  //         headerImageHeightPts = contentHeightPts * 0.3;
  //       }
  //     }
  //     final pointsPerPixel = contentWidthPts / bodyUi.width;
  //     final firstAvailPts = math.max(
  //       0,
  //       contentHeightPts -
  //           (headerUi != null ? (headerImageHeightPts + spacingPts) : 0),
  //     );
  //     final sliceFirstPx = math.max(
  //       1,
  //       (firstAvailPts / pointsPerPixel).floor(),
  //     );
  //     final slicePx = math.max(1, (contentHeightPts / pointsPerPixel).floor());
  //     final segments = <Uint8List>[];
  //     var y = 0;
  //     if (sliceFirstPx > 0) {
  //       final h = math.min(sliceFirstPx, bodyUi.height - y);
  //       final seg = await _cropToPngBytes(bodyUi, y, h);
  //       segments.add(seg);
  //       y += h;
  //     }
  //     while (y < bodyUi.height) {
  //       final h = math.min(slicePx, bodyUi.height - y);
  //       final seg = await _cropToPngBytes(bodyUi, y, h);
  //       segments.add(seg);
  //       y += h;
  //     }
  //     doc.addPage(
  //       pw.MultiPage(
  //         pageFormat: pdf.PdfPageFormat.a4,
  //         margin: pw.EdgeInsets.all(marginPts),
  //         header: (context) {
  //           if (context.pageNumber == 1 && headerBytes != null) {
  //             final headerImage = pw.MemoryImage(headerBytes);
  //             return pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.stretch,
  //               children: [
  //                 pw.Image(headerImage, fit: pw.BoxFit.fitWidth),
  //                 pw.SizedBox(height: spacingPts),
  //               ],
  //             );
  //           }
  //           return pw.SizedBox();
  //         },
  //         build: (context) => segments
  //             .map(
  //               (seg) => pw.Image(pw.MemoryImage(seg), fit: pw.BoxFit.fitWidth),
  //             )
  //             .toList(),
  //       ),
  //     );
  //     final pdfBytes = await doc.save();
  //     final file = XFile.fromData(
  //       pdfBytes,
  //       name: name,
  //       mimeType: 'application/pdf',
  //     );
  //     final path = await _getSavePathWithFallback(
  //       name,
  //       const XTypeGroup(label: 'PDF', extensions: ['pdf']),
  //     );
  //     if (path == null) {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('تعذر تحديد مسار الحفظ')));
  //       return;
  //     }
  //     await file.saveTo(path);
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('تم حفظ الملف في: $path')));
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('فشل حفظ الملف: $e')));
  //   }
  // }

  // Future<Uint8List> _cropToPngBytes(ui.Image source, int y, int h) async {
  //   final recorder = ui.PictureRecorder();
  //   final canvas = Canvas(recorder);
  //   final src = Rect.fromLTWH(
  //     0,
  //     y.toDouble(),
  //     source.width.toDouble(),
  //     h.toDouble(),
  //   );
  //   final dst = Rect.fromLTWH(0, 0, source.width.toDouble(), h.toDouble());
  //   canvas.drawImageRect(source, src, dst, Paint());
  //   final picture = recorder.endRecording();
  //   final img = await picture.toImage(source.width, h);
  //   final data = await img.toByteData(format: ui.ImageByteFormat.png);
  //   return data!.buffer.asUint8List();
  // }

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
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
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
                          // const SizedBox(width: 12),
                          // ElevatedButton.icon(
                          //   onPressed: _saveAsPdf,
                          //   icon: const Icon(Icons.picture_as_pdf),
                          //   label: const Text('حفظ PDF'),
                          // ),
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
                            Flexible(
                              child: Text(
                                o == "محافظة"
                                    ? "$o (دمشق ومراكز المحافظات الأخرى)"
                                    : o,
                              ),
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
