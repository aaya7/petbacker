import 'package:bloc/bloc.dart';
import 'package:petbacker/repositories/pet_repository.dart';
import 'pet_event.dart';
import 'pet_state.dart';

class PetsBloc extends Bloc<PetEvent, PetsState> {
  final PetRepository repository;

  PetsBloc(this.repository) : super(PetsInitial()) {
    on<FetchPets>((event, emit) async {
      emit(PetsLoading());
      try {
        final pets = await repository.fetchPets();
        emit(PetsLoaded(pets));
      } catch (e) {
        emit(PetsError(e.toString()));
      }
    });
  }
}
