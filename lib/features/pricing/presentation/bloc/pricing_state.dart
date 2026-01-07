import 'package:equatable/equatable.dart';
import '../../domain/form_models.dart';

class PricingState extends Equatable {
  final FormSchema? schema;
  final Map<String, dynamic> values;
  final double? totalPrice;
  final bool submitted;

  const PricingState({this.schema, this.values = const {}, this.totalPrice, this.submitted = false});

  PricingState copyWith({FormSchema? schema, Map<String, dynamic>? values, double? totalPrice, bool? submitted}) {
    return PricingState(
      schema: schema ?? this.schema,
      values: values ?? this.values,
      totalPrice: totalPrice ?? this.totalPrice,
      submitted: submitted ?? this.submitted,
    );
  }

  @override
  List<Object?> get props => [schema, values, totalPrice, submitted];
}