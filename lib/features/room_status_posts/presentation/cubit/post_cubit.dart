import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/room_status_posts/domain/entities/post.dart';
import 'package:huddle/features/room_status_posts/domain/repos/post_repo.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;

  PostCubit({
    required this.postRepo,
  }) : super(PostsInitial());

  // Create a new post
  Future<void> createPost(Post post) async {
    try {
      await postRepo.createPost(post);
    } catch (e) {
      emit(PostsError('Failed to create post: $e'));
    }
  }

  // Fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError('Failed to fetch posts: $e'));
    }
  }

  // Fetch posts by user ID
  Future<void> fetchPostByUserID(String userId) async {
    try {
      emit(PostsLoading());
      final userPosts = await postRepo.fetchPostByUserID(userId);
      emit(PostsLoaded(userPosts));
    } catch (e) {
      emit(PostsError('Failed to fetch user-specific posts: $e'));
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsError('Failed to delete post: $e'));
    }
  }
}
