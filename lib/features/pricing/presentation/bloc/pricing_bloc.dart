import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/form_schemas.dart';
import '../../domain/calculate_price.dart';
import 'pricing_event.dart';
import 'pricing_state.dart';

class PricingBloc extends Bloc<PricingEvent, PricingState> {
  PricingBloc() : super(const PricingState()) {
    on<InitializePricing>((event, emit) {
      final schema = FormSchemas.all.firstWhere((s) => s.typeId == event.type.id);
      emit(PricingState(schema: schema, values: const {}));
    });

    on<UpdateField>((event, emit) {
      final values = Map<String, dynamic>.from(state.values);
      values[event.id] = event.value;
      if (state.schema != null) {
        for (final f in state.schema!.fields) {
          if (f.dependsOn == event.id) {
            final depVal = values[f.dependsOn];
            bool visible;
            if (f.dependsOnNotEmpty) {
              visible = depVal != null && depVal.toString().isNotEmpty;
            } else if (f.dependsOnEquals != null) {
              visible = depVal == f.dependsOnEquals;
            } else {
              visible = depVal != null;
            }
            if (!visible && values.containsKey(f.id)) {
              values.remove(f.id);
            }
          }
        }
      }
      emit(state.copyWith(values: values, submitted: false, totalPrice: null));
    });

    on<SubmitPricing>((event, emit) {
      if (state.schema == null) return;
      final total = calculatePrice(type: event.type, schema: state.schema!, values: state.values);
      emit(state.copyWith(totalPrice: total, submitted: true));
    });
  }
}