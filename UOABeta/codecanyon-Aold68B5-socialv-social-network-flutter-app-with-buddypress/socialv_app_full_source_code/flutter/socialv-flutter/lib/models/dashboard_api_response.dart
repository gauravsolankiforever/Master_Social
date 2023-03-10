class DashboardAPIResponse {
  int? notificationCount;
  List<VisibilityOptions>? visibilities;
  List<ReportType>? reportTypes;
  List<dynamic>? storyAllowedTypes;

  DashboardAPIResponse({this.notificationCount, this.visibilities, this.storyAllowedTypes, this.reportTypes});

  factory DashboardAPIResponse.fromJson(Map<String, dynamic> json) {
    return DashboardAPIResponse(
      notificationCount: json['notification_count'],
      visibilities: json['visibilities'] != null ? (json['visibilities'] as List).map((i) => VisibilityOptions.fromJson(i)).toList() : null,
      reportTypes: json['report_types'] != null ? (json['report_types'] as List).map((i) => ReportType.fromJson(i)).toList() : null,
      storyAllowedTypes: json['story_allowed_types'] != null ? (json['story_allowed_types'] as List).map((i) => i.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notification_count'] = this.notificationCount;
    if (this.visibilities != null) {
      data['visibilities'] = this.visibilities!.map((v) => v.toJson()).toList();
    }
    if (this.storyAllowedTypes != null) {
      data['story_allowed_types'] = this.storyAllowedTypes!.map((v) => v.toJson()).toList();
    }

    if (this.reportTypes != null) {
      data['report_types'] = this.reportTypes!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class VisibilityOptions {
  String? id;
  String? label;

  VisibilityOptions({this.id, this.label});

  factory VisibilityOptions.fromJson(Map<String, dynamic> json) {
    return VisibilityOptions(
      id: json['id'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['label'] = this.label;
    return data;
  }
}

class ReportType {
  String? key;
  String? label;

  ReportType({this.key, this.label});

  factory ReportType.fromJson(Map<String, dynamic> json) {
    return ReportType(
      key: json['key'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['label'] = this.label;
    return data;
  }
}
