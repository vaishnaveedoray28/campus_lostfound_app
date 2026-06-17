class UserModel {
  final int id;
  final String name;
  final String email;
  final String matricNo;
  final String inasis;
  final String phone;
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.matricNo,
    required this.inasis,
    required this.phone,
    required this.points,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      matricNo: json['matric_no'] ?? '',
      inasis: json['inasis'] ?? '',
      phone: json['phone'] ?? '',
      points: json['points'] is String ? int.parse(json['points']) : json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'matric_no': matricNo,
      'inasis': inasis,
      'phone': phone,
      'points': points,
    };
  }
}