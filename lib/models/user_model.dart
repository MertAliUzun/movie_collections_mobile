class User {
  final String userName;
  final String email;
  final String password;
  final DateTime? watchDate;
  final double? userScore;

  User({
    required this.userName,
    required this.email,
    required this.password,
    this.watchDate,
    this.userScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'email': email,
      'password': password,
      'watch_date': watchDate?.toIso8601String(),
      'user_score': userScore,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['user_name'],
      email: json['email'],
      password: json['password'],
      watchDate: json['watch_date'] != null ? DateTime.parse(json['watch_date']) : null,
      userScore: json['user_score']?.toDouble(),
    );
  }
} 