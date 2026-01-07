import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../mosque_type/domain/mosque_type.dart';
import '../../domain/form_models.dart';
import '../../domain/form_schemas.dart';
import '../../domain/calculate_price.dart';

class PricingState extends Equatable {
  final FormSchema? schema;
  final Map<String, dynamic> values;
  final double? totalPrice;
  final bool submitted;

  const PricingState({
    this.schema,
    this.values = const {},
    this.totalPrice,
    this.submitted = false,
  });

  PricingState copyWith({
    FormSchema? schema,
    Map<String, dynamic>? values,
    double? totalPrice,
    bool? submitted,
  }) {
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

class PricingCubit extends Cubit<PricingState> {
  PricingCubit() : super(const PricingState());

  void initialize(MosqueType type) {
    final schema = FormSchemas.all.firstWhere((s) => s.typeId == type.id);
    emit(PricingState(schema: schema, values: const {}));
  }

  void updateValue(String id, dynamic value) {
    final values = Map<String, dynamic>.from(state.values);
    values[id] = value;
    emit(state.copyWith(values: values, submitted: false, totalPrice: null));
  }

  void submit(MosqueType type) {
    if (state.schema == null) return;
    final total = calculatePrice(type: type, schema: state.schema!, values: state.values);
    emit(state.copyWith(totalPrice: total, submitted: true));
  }
}