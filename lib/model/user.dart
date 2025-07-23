
class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String idAsli;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.idAsli,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phone'] ?? '',
      idAsli: json['idAsli'] ?? '',
    );
  }
}