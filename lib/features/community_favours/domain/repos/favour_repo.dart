import 'package:huddle/features/community_favours/domain/entities/favour.dart';

abstract class FavourRepo {
  Future<List<Favour>> fetchAllFavours();
  Future<void> createFavour(Favour favour);
  Future<void> deleteFavour(String favourId);
  Future<List<Favour>> fetchFavourByUserID(String userId);
}
