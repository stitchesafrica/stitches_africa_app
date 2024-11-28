class ManualCalculationModel {
  final String taskSetUrl;

  ManualCalculationModel({required this.taskSetUrl});

  factory ManualCalculationModel.fromJson(Map<String, dynamic> json) {
    return ManualCalculationModel(
      taskSetUrl: json['task_set_url'],
    );
  }
}
