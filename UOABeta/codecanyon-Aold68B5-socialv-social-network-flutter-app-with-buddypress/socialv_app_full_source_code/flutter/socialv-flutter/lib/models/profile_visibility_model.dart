class ProfileVisibilityModel {
  List<Field>? fields;
  String? groupName;

  ProfileVisibilityModel({this.fields, this.groupName});

  factory ProfileVisibilityModel.fromJson(Map<String, dynamic> json) {
    return ProfileVisibilityModel(
      fields: json['fields'] != null ? (json['fields'] as List).map((i) => Field.fromJson(i)).toList() : null,
      groupName: json['group_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_name'] = this.groupName;
    if (this.fields != null) {
      data['fields'] = this.fields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Field {
  bool? canChange;
  int? id;
  String? level;
  String? name;
  String? visibility;

  Field({this.canChange, this.id, this.level, this.name, this.visibility});

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      canChange: json['can_change'],
      id: json['id'],
      level: json['level'],
      name: json['name'],
      visibility: json['visibility'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['can_change'] = this.canChange;
    data['id'] = this.id;
    data['level'] = this.level;
    data['name'] = this.name;
    data['visibility'] = this.visibility;
    return data;
  }
}
