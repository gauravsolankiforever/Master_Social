import 'package:flutter/material.dart';
import 'package:story_time/story_page_view/story_page_view.dart';

class StoryResponseModel {
  String? avatarUrl;
  List<StoryItem>? items;
  int? lastUpdated;
  String? name;
  bool? seen;
  int? userId;

  AnimationController? animationController;
  bool? showBorder;

  StoryResponseModel({
    this.avatarUrl,
    this.items,
    this.lastUpdated,
    this.name,
    this.seen,
    this.userId,
    this.animationController,
    this.showBorder = true,
  });

  factory StoryResponseModel.fromJson(Map<String, dynamic> json) {
    return StoryResponseModel(
      avatarUrl: json['avarat_url'],
      items: json['items'] != null ? (json['items'] as List).map((i) => StoryItem.fromJson(i)).toList() : null,
      lastUpdated: json['lastUpdated'],
      name: json['name'],
      seen: json['seen'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avarat_url'] = this.avatarUrl;
    data['lastUpdated'] = this.lastUpdated;
    data['name'] = this.name;
    data['seen'] = this.seen;

    data['user_id'] = this.userId;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StoryItem {
  dynamic? duration;
  dynamic? id;
  dynamic? index;
  String? mediaType;
  bool? seen;
  String? storyLink;
  String? storyMedia;
  String? storyText;
  dynamic? time;
  String? uniqueId;
  dynamic? viewCount;

  StoryItem({
    this.duration,
    this.id,
    this.index,
    this.mediaType,
    this.seen,
    this.storyLink,
    this.storyMedia,
    this.storyText,
    this.time,
    this.uniqueId,
    this.viewCount,
  });

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    return StoryItem(
      duration:json['duration'].toString(),
      id: json['id'].toString(),
      index: json['index'].toString(),
      mediaType: json['media_type'],
      seen: json['seen'],
      storyLink: json['story_link'],
      storyMedia: json['story_media'],
      storyText: json['story_text'],
      time: json['time'].toString(),
      uniqueId: json['uniq_id'],
      viewCount: json['view_count'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['duration'] = this.duration;
    data['id'] = this.id;
    data['index'] = this.index;
    data['media_type'] = this.mediaType;
    data['seen'] = this.seen;
    data['story_link'] = this.storyLink;
    data['story_media'] = this.storyMedia;
    data['story_text'] = this.storyText;
    data['time'] = this.time;
    data['uniq_id'] = this.uniqueId;
    data['view_count'] = this.viewCount;
    return data;
  }
}
