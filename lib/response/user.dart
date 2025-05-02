class UserResponse {
  String? message;
  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? role;
  String? avatarUrl;
  Map<String, dynamic>? data;

  UserResponse(
      {this.message,
      this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.role,
      this.avatarUrl,
      this.data});

  UserResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? json['data'] : null;

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = id;
      data['name'] = name;
      data['email'] = email;
      data['phone'] = phoneNumber;
      data['role'] = role;
      data['avatarUrl'] = avatarUrl;
      return data;
    }
  }
}
