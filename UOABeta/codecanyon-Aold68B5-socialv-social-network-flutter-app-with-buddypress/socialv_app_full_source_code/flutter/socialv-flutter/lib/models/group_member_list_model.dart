class GroupMemberListModel {
  bool? isAdmin;
  String? mentionName;
  String? userAvatar;
  int? userId;
  String? userName;

  GroupMemberListModel({this.isAdmin, this.mentionName, this.userAvatar, this.userId, this.userName});

  factory GroupMemberListModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberListModel(
      isAdmin: json['is_admin'],
      mentionName: json['mention_name'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_admin'] = this.isAdmin;
    data['mention_name'] = this.mentionName;
    data['user_avatar'] = this.userAvatar;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    return data;
  }
}
