class InviteUserListModel {
  bool? isInvited;
  int? userId;
  String? userImage;
  String? userName;

  InviteUserListModel({this.isInvited, this.userId, this.userImage, this.userName});

  factory InviteUserListModel.fromJson(Map<String, dynamic> json) {
    return InviteUserListModel(
      isInvited: json['is_invited'],
      userId: json['user_Id'],
      userImage: json['user_image'],
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_invited'] = this.isInvited;
    data['user_Id'] = this.userId;
    data['user_image'] = this.userImage;
    data['user_name'] = this.userName;
    return data;
  }
}
