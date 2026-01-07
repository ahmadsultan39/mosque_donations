enum FieldType { number, text, dropdown, boolean }

class FormFieldSpec {
  final String id;
  final String labelAr;
  final FieldType type;
  final List<String>? options;
  final double? min;
  final double? max;
  final bool required;
  final String? dependsOn;
  final Object? dependsOnEquals;
  final bool dependsOnNotEmpty;

  const FormFieldSpec({
    required this.id,
    required this.labelAr,
    required this.type,
    this.options,
    this.min,
    this.max,
    this.required = true,
    this.dependsOn,
    this.dependsOnEquals,
    this.dependsOnNotEmpty = false,
  });
}

class FormSchema {
  final String typeId;
  final List<FormFieldSpec> fields;

  const FormSchema({
    required this.typeId,
    required this.fields,
  });
}