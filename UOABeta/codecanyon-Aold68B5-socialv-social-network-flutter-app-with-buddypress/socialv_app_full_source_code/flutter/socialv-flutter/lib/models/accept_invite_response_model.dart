import 'package:socialv/models/avatar_urls.dart';
import 'package:socialv/models/collection.dart';
import 'package:socialv/models/self.dart';
import 'package:socialv/models/user.dart';

class AcceptInviteResponseModel {
  Links? links;
  AvatarUrls? avatarUrls;
  String? dateModified;
  String? dateModifiedGmt;
  bool? friendshipStatus;
  String? friendshipStatusSlug;
  int? group;
  int? id;
  bool? isAdmin;
  bool? isBanned;
  bool? isConfirmed;
  bool? isMod;
  String? link;
  String? mentionName;
  String? name;
  String? registeredDate;
  String? registeredDateGmt;
  String? userLogin;

  AcceptInviteResponseModel({
    this.links,
    this.avatarUrls,
    this.dateModified,
    this.dateModifiedGmt,
    this.friendshipStatus,
    this.friendshipStatusSlug,
    this.group,
    this.id,
    this.isAdmin,
    this.isBanned,
    this.isConfirmed,
    this.isMod,
    this.link,
    this.mentionName,
    this.name,
    this.registeredDate,
    this.registeredDateGmt,
    this.userLogin,
  });

  factory AcceptInviteResponseModel.fromJson(Map<String, dynamic> json) {
    return AcceptInviteResponseModel(
      links: json['_links'] != null ? Links.fromJson(json['_links']) : null,
      avatarUrls: json['avatar_urls'] != null ? AvatarUrls.fromJson(json['avatar_urls']) : null,
      dateModified: json['date_modified'],
      dateModifiedGmt: json['date_modified_gmt'],
      friendshipStatus: json['friendship_status'],
      friendshipStatusSlug: json['friendship_status_slug'],
      group: json['group'],
      id: json['id'],
      isAdmin: json['is_admin'],
      isBanned: json['is_banned'],
      isConfirmed: json['is_confirmed'],
      isMod: json['is_mod'],
      link: json['link'],
      mentionName: json['mention_name'],
      name: json['name'],
      registeredDate: json['registered_date'],
      registeredDateGmt: json['registered_date_gmt'],
      userLogin: json['user_login'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date_modified'] = this.dateModified;
    data['date_modified_gmt'] = this.dateModifiedGmt;
    data['friendship_status'] = this.friendshipStatus;
    data['friendship_status_slug'] = this.friendshipStatusSlug;
    data['group'] = this.group;
    data['id'] = this.id;
    data['is_admin'] = this.isAdmin;
    data['is_banned'] = this.isBanned;
    data['is_confirmed'] = this.isConfirmed;
    data['is_mod'] = this.isMod;
    data['link'] = this.link;
    data['mention_name'] = this.mentionName;
    data['name'] = this.name;
    data['user_login'] = this.userLogin;
    if (this.links != null) {
      data['_links'] = this.links!.toJson();
    }
    if (this.avatarUrls != null) {
      data['avatar_urls'] = this.avatarUrls!.toJson();
    }

    if (this.registeredDate != null) {
      data['registered_date'] = this.registeredDate;
    }
    if (this.registeredDateGmt != null) {
      data['registered_date_gmt'] = this.registeredDateGmt;
    }

    return data;
  }
}

class Links {
  List<Collection>? collection;
  List<Self>? self;
  List<User>? user;

  Links({this.collection, this.self, this.user});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      collection: json['collection'] != null ? (json['collection'] as List).map((i) => Collection.fromJson(i)).toList() : null,
      self: json['self'] != null ? (json['self'] as List).map((i) => Self.fromJson(i)).toList() : null,
      user: json['group'] != null ? (json['group'] as List).map((i) => User.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.collection != null) {
      data['collection'] = this.collection!.map((v) => v.toJson()).toList();
    }
    if (this.self != null) {
      data['self'] = this.self!.map((v) => v.toJson()).toList();
    }
    if (this.user != null) {
      data['group'] = this.user!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
