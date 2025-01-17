import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favour.dart';
import '../../domain/repos/favour_repo.dart';

part 'favour_state.dart';

class FavourCubit extends Cubit<FavourState> {
  final FavourRepo favourRepo;
  List<Favour> allFavours = []; // Store all favours here.

  FavourCubit({required this.favourRepo}) : super(FavoursInitial());

  // Create a new favour
  Future<void> createFavour(Favour favour) async {
    try {
      await favourRepo.createFavour(favour);
    } catch (e) {
      emit(FavoursError('Failed to create favour: $e'));
    }
  }

  // Fetch all favours
  Future<void> fetchAllFavours() async {
    try {
      emit(FavoursLoading());
      allFavours = await favourRepo.fetchAllFavours();
      emit(FavoursLoaded(allFavours));
    } catch (e) {
      emit(FavoursError('Failed to fetch favours: $e'));
    }
  }

  // Fetch favours by user ID
  Future<void> fetchFavourByUserID(String userId) async {
    try {
      emit(FavoursLoading());
      final userFavours = await favourRepo.fetchFavourByUserID(userId);
      emit(FavoursLoaded(userFavours));
    } catch (e) {
      emit(FavoursError('Failed to fetch user-specific favours: $e'));
    }
  }

  // Delete a favour
  Future<void> deleteFavour(String favourId) async {
    try {
      await favourRepo.deleteFavour(favourId);
    } catch (e) {
      emit(FavoursError('Failed to delete favour: $e'));
    }
  }
}
