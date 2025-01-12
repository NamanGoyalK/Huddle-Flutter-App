import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huddle/features/room_status_posts/domain/entities/post.dart';
import 'package:huddle/features/room_status_posts/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Store the posts in a collection called posts.
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('Posts');
  @override
  Future<void> createPost(Post post) async {
    //Create a new post in the posts collection.
    try {
      await postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    //Delete post in firebase.
    await postCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      //Get all the posts from the firestore with the most recent on the top.
      final postsSnapshot =
          await postCollection.orderBy('scheduledTime', descending: true).get();

      //Convert each firestore document from json --> list of posts
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception('Error fetching the posts: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostByUserID(String userId) async {
    try {
      //Fetch posts using userID
      final postSnapshot =
          await postCollection.where('userId', isEqualTo: userId).get();

      //Convert the posts from Json --> List of posts
      final List<Post> userPosts = postSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception('Error fetching posts by user: $e');
    }
  }
}
