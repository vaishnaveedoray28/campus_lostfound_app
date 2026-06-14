
class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.points,
  });

  // Factory constructor to instantly convert incoming JSON data into a Dart object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      points: json['points'] is String ? int.parse(json['points']) : (json['points'] ?? 0),
    );
  }

  // Method to turn a Dart user model back into JSON formatting if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'points': points,
    };
  }
}