part of 'post_cubit.dart';

//Post States

abstract class PostState {}

//Initial State
class PostsInitial extends PostState {}

//Loading State
class PostsLoading extends PostState {}

//Uploading State
class PostsUploading extends PostState {}

//Loaded State
class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}

//Error State
class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}
