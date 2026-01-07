import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/mosque_type.dart';

class MosqueTypeCubit extends Cubit<MosqueType?> {
  MosqueTypeCubit() : super(null);

  void select(MosqueType type) => emit(type);
  void clear() => emit(null);
}