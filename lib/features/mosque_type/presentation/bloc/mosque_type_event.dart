import '../../domain/mosque_type.dart';

abstract class MosqueTypeEvent {}

class SelectMosqueType extends MosqueTypeEvent {
  final MosqueType type;
  SelectMosqueType(this.type);
}

class ClearMosqueType extends MosqueTypeEvent {}