class RemoveExistingFriend {
  bool? deleted;
  Previous? previous;

  RemoveExistingFriend({this.deleted, this.previous});

  factory RemoveExistingFriend.fromJson(Map<String, dynamic> json) {
    return RemoveExistingFriend(
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
  String? date_created;
  String? date_created_gmt;
  int? friend_id;
  int? id;
  int? initiator_id;
  bool? is_confirmed;

  Previous({this.date_created, this.date_created_gmt, this.friend_id, this.id, this.initiator_id, this.is_confirmed});

  factory Previous.fromJson(Map<String, dynamic> json) {
    return Previous(
      date_created: json['date_created'],
      date_created_gmt: json['date_created_gmt'],
      friend_id: json['friend_id'],
      id: json['id'],
      initiator_id: json['initiator_id'],
      is_confirmed: json['is_confirmed'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date_created'] = this.date_created;
    data['date_created_gmt'] = this.date_created_gmt;
    data['friend_id'] = this.friend_id;
    data['id'] = this.id;
    data['initiator_id'] = this.initiator_id;
    data['is_confirmed'] = this.is_confirmed;
    return data;
  }
}
