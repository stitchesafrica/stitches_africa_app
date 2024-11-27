class PersonModel {
  final int id;
  final int userId;
  final String gender;
  final int height;
  final double weight;

  PersonModel(
      {required this.id,
      required this.userId,
      required this.gender,
      required this.height,
      required this.weight});

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'],
      userId: json['user_id'],
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
    );
  }
}
