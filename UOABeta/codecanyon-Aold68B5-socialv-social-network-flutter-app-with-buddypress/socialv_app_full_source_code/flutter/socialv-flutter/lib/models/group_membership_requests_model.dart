import 'links.dart';

class GroupMembershipRequestsModel {
  Links? links;
  String? date_modified;
  int? group_id;
  int? id;
  int? invite_sent;
  int? inviter_id;
  Message? message;
  String? type;
  int? user_id;

  GroupMembershipRequestsModel({this.links, this.date_modified, this.group_id, this.id, this.invite_sent, this.inviter_id, this.message, this.type, this.user_id});

  factory GroupMembershipRequestsModel.fromJson(Map<String, dynamic> json) {
    return GroupMembershipRequestsModel(
      links: json['_links'] != null ? Links.fromJson(json['_links']) : null,
      date_modified: json['date_modified'],
      group_id: json['group_id'],
      id: json['id'],
      invite_sent: json['invite_sent'],
      inviter_id: json['inviter_id'],
      message: json['message'] != null ? Message.fromJson(json['message']) : null,
      type: json['type'],
      user_id: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date_modified'] = this.date_modified;
    data['group_id'] = this.group_id;
    data['id'] = this.id;
    data['invite_sent'] = this.invite_sent;
    data['inviter_id'] = this.inviter_id;
    data['type'] = this.type;
    data['user_id'] = this.user_id;
    if (this.links != null) {
      data['_links'] = this.links!.toJson();
    }
    if (this.message != null) {
      data['message'] = this.message!.toJson();
    }
    return data;
  }
}

class Message {
  String? raw;
  String? rendered;

  Message({this.raw, this.rendered});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      raw: json['raw'],
      rendered: json['rendered'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['raw'] = this.raw;
    data['rendered'] = this.rendered;
    return data;
  }
}
