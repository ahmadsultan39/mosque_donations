import '../../../mosque_type/domain/mosque_type.dart';

abstract class PricingEvent {}

class InitializePricing extends PricingEvent {
  final MosqueType type;
  InitializePricing(this.type);
}

class UpdateField extends PricingEvent {
  final String id;
  final dynamic value;
  UpdateField(this.id, this.value);
}

class SubmitPricing extends PricingEvent {
  final MosqueType type;
  SubmitPricing(this.type);
}