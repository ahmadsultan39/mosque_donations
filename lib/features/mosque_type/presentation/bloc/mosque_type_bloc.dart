import 'package:flutter_bloc/flutter_bloc.dart';
import 'mosque_type_event.dart';
import 'mosque_type_state.dart';

class MosqueTypeBloc extends Bloc<MosqueTypeEvent, MosqueTypeState> {
  MosqueTypeBloc() : super(const MosqueTypeState()) {
    on<SelectMosqueType>((event, emit) {
      emit(MosqueTypeState(selected: event.type));
    });
    on<ClearMosqueType>((event, emit) {
      emit(const MosqueTypeState(selected: null));
    });
  }
}