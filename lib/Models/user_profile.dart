class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  String? status;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    required this.status,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['pfpURL'] = pfpURL;
    data['uid'] = uid;
    data['status'] = status;
    return data;
  }
}