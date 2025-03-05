class User {
  final String nama;
  final String email;
  final String nomorTelepon;
  final String role;
  final String profilePicture;

  User({
    required this.nama,
    required this.email,
    required this.nomorTelepon,
    required this.role,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nama: json['nama'],
      email: json['email'],
      nomorTelepon: json['nomor_telepon'],
      role: json['role'],
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'email': email,
      'nomor_telepon': nomorTelepon,
      'role': role,
      'profile_picture': profilePicture,
    };
  }
}
