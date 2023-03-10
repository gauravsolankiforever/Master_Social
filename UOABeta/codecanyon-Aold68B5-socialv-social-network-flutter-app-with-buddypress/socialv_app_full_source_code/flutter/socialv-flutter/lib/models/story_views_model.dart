class StoryViewsModel {
  String? mentionName;
  String? seenTime;
  String? userAvatar;
  int? userId;
  String? userName;

  StoryViewsModel({this.mentionName, this.seenTime, this.userAvatar, this.userId, this.userName});

  factory StoryViewsModel.fromJson(Map<String, dynamic> json) {
    return StoryViewsModel(
      mentionName: json['mention_name'],
      seenTime: json['seen_time'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mention_name'] = this.mentionName;
    data['seen_time'] = this.seenTime;
    data['user_avatar'] = this.userAvatar;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    return data;
  }
}
