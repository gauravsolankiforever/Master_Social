class CommentModel {
  List<CommentModel>? children;
  String? content;
  String? dateRecorded;
  String? id;
  String? itemId; // post_id
  String? secondaryItemId; // parent comment id
  String? userEmail;
  String? userId;
  String? userImage;
  String? userName;

  CommentModel({this.children, this.content, this.dateRecorded, this.id, this.itemId, this.secondaryItemId, this.userEmail, this.userId, this.userImage, this.userName});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      children: json['children'] != null ? (json['children'] as List).map((i) => CommentModel.fromJson(i)).toList() : null,
      content: json['content'],
      dateRecorded: json['date_recorded'],
      id: json['id'],
      itemId: json['item_id'],
      secondaryItemId: json['secondary_item_id'],
      userEmail: json['user_email'],
      userId: json['user_id'],
      userImage: json['user_image'],
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['date_recorded'] = this.dateRecorded;
    data['id'] = this.id;
    data['item_id'] = this.itemId;
    data['secondary_item_id'] = this.secondaryItemId;
    data['user_email'] = this.userEmail;
    data['user_id'] = this.userId;
    data['user_image'] = this.userImage;
    data['user_name'] = this.userName;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/*
class Children {
    String content;
    String date_recorded;
    String id;
    String item_id;
    String secondary_item_id;
    String user_email;
    String user_id;
    String user_image;
    String user_name;

    Children({this.content, this.date_recorded, this.id, this.item_id, this.secondary_item_id, this.user_email, this.user_id, this.user_image, this.user_name});

    factory Children.fromJson(Map<String, dynamic> json) {
        return Children(
            content: json['content'], 
            date_recorded: json['date_recorded'], 
            id: json['id'], 
            item_id: json['item_id'], 
            secondary_item_id: json['secondary_item_id'], 
            user_email: json['user_email'], 
            user_id: json['user_id'], 
            user_image: json['user_image'], 
            user_name: json['user_name'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['content'] = this.content;
        data['date_recorded'] = this.date_recorded;
        data['id'] = this.id;
        data['item_id'] = this.item_id;
        data['secondary_item_id'] = this.secondary_item_id;
        data['user_email'] = this.user_email;
        data['user_id'] = this.user_id;
        data['user_image'] = this.user_image;
        data['user_name'] = this.user_name;
        return data;
    }
}*/
