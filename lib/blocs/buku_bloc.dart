import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/buku_repository.dart';

abstract class BukuEvent {}

class LoadBukuEvent extends BukuEvent {}

class AddBukuEvent extends BukuEvent {
  final Map<String, String> data;
  AddBukuEvent(this.data);
}

class EditBukuEvent extends BukuEvent {
  final Map<String, String> data;
  EditBukuEvent(this.data);
}

class DeleteBukuEvent extends BukuEvent {
  final String id;
  DeleteBukuEvent(this.id);
}

abstract class BukuState {}

class BukuInitial extends BukuState {}

class BukuLoading extends BukuState {}

class BukuLoaded extends BukuState {
  final List<dynamic> bukuList;
  BukuLoaded(this.bukuList);
}

class BukuOperationSuccess extends BukuState {
  final String message;
  BukuOperationSuccess(this.message);
}

class BukuError extends BukuState {
  final String message;
  BukuError(this.message);
}

class BukuBloc extends Bloc<BukuEvent, BukuState> {
  final BukuRepository repo;

  BukuBloc(this.repo) : super(BukuInitial()) {
    on<LoadBukuEvent>((event, emit) async {
      emit(BukuLoading());
      try {
        final data = await repo.getBuku();
        emit(BukuLoaded(data));
      } catch (e) {
        emit(BukuError("Gagal memuat data"));
      }
    });

    on<AddBukuEvent>((event, emit) async {
      emit(BukuLoading());
      try {
        await repo.saveBuku(event.data, false);
        emit(BukuOperationSuccess("Berhasil menambah data"));
        add(LoadBukuEvent());
      } catch (e) {
        emit(BukuError("Gagal menambah data"));
      }
    });

    on<EditBukuEvent>((event, emit) async {
      emit(BukuLoading());
      try {
        await repo.saveBuku(event.data, true);
        emit(BukuOperationSuccess("Berhasil update data"));
        add(LoadBukuEvent());
      } catch (e) {
        emit(BukuError("Gagal update data"));
      }
    });

    on<DeleteBukuEvent>((event, emit) async {
      try {
        await repo.deleteBuku(event.id);
        add(LoadBukuEvent());
      } catch (e) {
        emit(BukuError("Gagal hapus data"));
      }
    });
  }
}
