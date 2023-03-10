class DeleteNotificationResponseModel {
  bool? deleted;
  Previous? previous;

  DeleteNotificationResponseModel({this.deleted, this.previous});

  factory DeleteNotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteNotificationResponseModel(
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
  String? action;
  String? component;
  String? date;
  String? date_gmt;
  int? id;
  int? is_new;
  int? item_id;
  int? secondary_item_id;
  int? user_id;

  Previous({this.action, this.component, this.date, this.date_gmt, this.id, this.is_new, this.item_id, this.secondary_item_id, this.user_id});

  factory Previous.fromJson(Map<String, dynamic> json) {
    return Previous(
      action: json['action'],
      component: json['component'],
      date: json['date'],
      date_gmt: json['date_gmt'],
      id: json['id'],
      is_new: json['is_new'],
      item_id: json['item_id'],
      secondary_item_id: json['secondary_item_id'],
      user_id: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['action'] = this.action;
    data['component'] = this.component;
    data['date'] = this.date;
    data['date_gmt'] = this.date_gmt;
    data['id'] = this.id;
    data['is_new'] = this.is_new;
    data['item_id'] = this.item_id;
    data['secondary_item_id'] = this.secondary_item_id;
    data['user_id'] = this.user_id;
    return data;
  }
}
