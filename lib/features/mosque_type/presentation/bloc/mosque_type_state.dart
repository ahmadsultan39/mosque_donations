import '../../domain/mosque_type.dart';

class MosqueTypeState {
  final MosqueType? selected;
  const MosqueTypeState({this.selected});

  MosqueTypeState copyWith({MosqueType? selected}) => MosqueTypeState(selected: selected);
}