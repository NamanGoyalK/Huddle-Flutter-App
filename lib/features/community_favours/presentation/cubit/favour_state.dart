part of 'favour_cubit.dart';

// Favour States

abstract class FavourState {}

// Initial State
class FavoursInitial extends FavourState {}

// Loading State
class FavoursLoading extends FavourState {}

// Uploading State
class FavoursAdding extends FavourState {}

// Loaded State
class FavoursLoaded extends FavourState {
  final List<Favour> favours;
  FavoursLoaded(this.favours);
}

// Error State
class FavoursError extends FavourState {
  final String message;
  FavoursError(this.message);
}
