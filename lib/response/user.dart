class UserResponse {
  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? role;
  String? iat;
  String? exp;

  UserResponse({this.id, this.name, this.email, this.phoneNumber, this.role, this.iat, this.exp});

  UserResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone'];
    role = json['role'];
    iat = json['iat'];
    exp = json['exp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phoneNumber;
    data['role'] = role;
    data['iat'] = iat;
    data['exp'] = exp;
    return data;
  }
}