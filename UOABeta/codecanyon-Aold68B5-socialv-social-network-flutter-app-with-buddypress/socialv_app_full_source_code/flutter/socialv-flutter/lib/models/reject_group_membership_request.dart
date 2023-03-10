import 'package:socialv/models/user.dart';

class RejectGroupMembershipRequest {
  bool? deleted;
  Previous? previous;

  RejectGroupMembershipRequest({this.deleted, this.previous});

  factory RejectGroupMembershipRequest.fromJson(Map<String, dynamic> json) {
    return RejectGroupMembershipRequest(
      deleted: json['deleted'],
      previous: json['previous'] != null ? Previous.fromJson(json['previous']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deleted'] = this.deleted;
    if (this.previous != null) {
      data['previous'] = this.previous!.toJson();
    }
    return data;
  }
}

class Previous {
  String? date_modified;
  int? group_id;
  int? id;
  int? invite_sent;
  int? inviter_id;
  User? message;
  String? type;
  int? user_id;

  Previous({this.date_modified, this.group_id, this.id, this.invite_sent, this.inviter_id, this.message, this.type, this.user_id});

  factory Previous.fromJson(Map<String, dynamic> json) {
    return Previous(
      date_modified: json['date_modified'],
      group_id: json['group_id'],
      id: json['id'],
      invite_sent: json['invite_sent'],
      inviter_id: json['inviter_id'],
      message: json['message'] != null ? User.fromJson(json['message']) : null,
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
    if (this.message != null) {
      data['message'] = this.message!.toJson();
    }
    return data;
  }
}
