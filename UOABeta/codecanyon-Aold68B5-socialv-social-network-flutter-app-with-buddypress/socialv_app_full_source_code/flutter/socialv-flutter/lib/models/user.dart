class User {
  bool? embeddable;
  String? href;

  User({this.embeddable, this.href});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      embeddable: json['embeddable'],
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['embeddable'] = this.embeddable;
    data['href'] = this.href;
    return data;
  }
}
