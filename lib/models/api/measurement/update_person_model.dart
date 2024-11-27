class UpdatePersonModel {
  final String taskSetUrl;

  UpdatePersonModel({required this.taskSetUrl});

  factory UpdatePersonModel.fromJson(Map<String, dynamic> json) {
    return UpdatePersonModel(
      taskSetUrl: json['task_set_url'],
    );
  }
}
