import 'package:socialv/models/comment_model.dart';
import 'package:socialv/models/get_post_likes_model.dart';

class PostModel {
  int? activityId;
  int? commentCount;
  List<CommentModel>? comments;
  String? content;
  String? dateRecorded;
  bool? isFavorites;
  bool? isLiked;
  int? likeCount;
  List<String>? mediaList;
  String? mediaType;
  String? postIn;
  String? userEmail;
  int? userId;
  String? userImage;
  String? userName;
  List<GetPostLikesModel>? usersWhoLiked;

  PostModel(
      {this.activityId,
      this.commentCount,
      this.comments,
      this.content,
      this.dateRecorded,
      this.isFavorites,
      this.isLiked,
      this.likeCount,
      this.mediaList,
      this.mediaType,
      this.postIn,
      this.userEmail,
      this.userId,
      this.userImage,
      this.userName,
      this.usersWhoLiked});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      activityId: json['activity_id'],
      commentCount: json['comment_count'],
      comments: json['comments'] != null ? (json['comments'] as List).map((i) => CommentModel.fromJson(i)).toList() : null,
      content: json['content'],
      dateRecorded: json['date_recorded'],
      isFavorites: json['is_favorites'],
      isLiked: json['is_liked'],
      likeCount: json['like_count'],
      mediaList: json['media_list'] != null ? new List<String>.from(json['media_list']) : null,
      mediaType: json['media_type'],
      postIn: json['post_in'],
      userEmail: json['user_email'],
      userId: json['user_id'],
      userImage: json['user_image'],
      userName: json['User_name'],
      usersWhoLiked: json['users_who_liked'] != null ? (json['users_who_liked'] as List).map((i) => GetPostLikesModel.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activity_id'] = this.activityId;
    data['comment_count'] = this.commentCount;
    data['content'] = this.content;
    data['date_recorded'] = this.dateRecorded;
    data['is_favorites'] = this.isFavorites;
    data['is_liked'] = this.isLiked;
    data['like_count'] = this.likeCount;
    data['media_type'] = this.mediaType;
    data['post_in'] = this.postIn;
    data['user_email'] = this.userEmail;
    data['user_id'] = this.userId;
    data['user_image'] = this.userImage;
    data['User_name'] = this.userName;
    if (this.comments != null) {
      data['comments'] = this.comments!.map((v) => v.toJson()).toList();
    }
    if (this.mediaList != null) {
      data['media_list'] = this.mediaList;
    }
    if (this.usersWhoLiked != null) {
      data['users_who_liked'] = this.usersWhoLiked!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
