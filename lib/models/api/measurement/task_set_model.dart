class TaskSetModel {
  final Map<String, dynamic>? taskSet;
  final Map<String, dynamic>? volumeParams;
  final Map<String, dynamic>? sideParams;
  final Map<String, dynamic>? frontParams;

  TaskSetModel({
    required this.taskSet,
    required this.volumeParams,
    required this.sideParams,
    required this.frontParams,
  });

  factory TaskSetModel.fromJson(Map<String, dynamic> json) {
    return TaskSetModel(
      taskSet: json['task_set'] as Map<String, dynamic>?,
      volumeParams: json['volume_params'] as Map<String, dynamic>?,
      sideParams: json['side_params'] as Map<String, dynamic>?,
      frontParams: json['front_params'] as Map<String, dynamic>?,
    );
  }
}
/*class TaskSetModel {
  final TaskSet taskSet;
  final VolumeParams volumeParams;
  final SideParams sideParams;
  final FrontParams frontParams;

  TaskSetModel({
    required this.taskSet,
    required this.volumeParams,
    required this.sideParams,
    required this.frontParams,
  });

  factory TaskSetModel.fromJson(Map<String, dynamic> json) {
    return TaskSetModel(
      taskSet: TaskSet.fromJson(json['task_set']),
      volumeParams: VolumeParams.fromJson(json['volume_params']),
      sideParams: SideParams.fromJson(json['side_params']),
      frontParams: FrontParams.fromJson(json['front_params']),
    );
  }
} */

class TaskSet {
  final bool isSuccessful;
  final bool isReady;
  final List<SubTask> subTasks;

  TaskSet({
    required this.isSuccessful,
    required this.isReady,
    required this.subTasks,
  });

  factory TaskSet.fromJson(Map<String, dynamic> json) {
    return TaskSet(
      isSuccessful: json['is_successful'] ?? false,
      isReady: json['is_ready'] ?? false,
      subTasks: (json['sub_tasks'] as List)
          .map((subTask) => SubTask.fromJson(subTask))
          .toList(),
    );
  }
}

class SubTask {
  final String name;
  final String status;
  final String taskId;
  final String message;

  SubTask({
    required this.name,
    required this.status,
    required this.taskId,
    required this.message,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      taskId: json['task_id'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class VolumeParams {
  final double chest;
  final double waist;
  final double hip;
  final double underBustGirth;
  final double upperChestGirth;
  final double overarmGirth;
  final double highHips;
  final double alternativeWaistGirth;
  final double pantWaist;
  final double abdomen;
  final double bicep;
  final double upperBicepGirth;
  final double upperKneeGirth;
  final double knee;
  final double ankle;
  final double wrist;
  final double calf;
  final double thigh;
  final double midThighGirth;
  final double neck;
  final double armscyeGirth;
  final double neckGirth;
  final double forearm;
  final double elbowGirth;

  // Add more fields as needed...

  VolumeParams({
    required this.chest,
    required this.waist,
    required this.hip,
    required this.underBustGirth,
    required this.upperChestGirth,
    required this.overarmGirth,
    required this.highHips,
    required this.alternativeWaistGirth,
    required this.pantWaist,
    required this.abdomen,
    required this.bicep,
    required this.upperBicepGirth,
    required this.upperKneeGirth,
    required this.knee,
    required this.ankle,
    required this.wrist,
    required this.calf,
    required this.thigh,
    required this.midThighGirth,
    required this.neck,
    required this.armscyeGirth,
    required this.neckGirth,
    required this.forearm,
    required this.elbowGirth,
  });

  factory VolumeParams.fromJson(Map<String, dynamic> json) {
    return VolumeParams(
      chest: json['chest'] ?? 0.0,
      waist: json['waist'] ?? 0.0,
      hip: json['low_hips'] ?? 0.0,
      underBustGirth: json['under_bust_girth'] ?? 0.0,
      upperChestGirth: json['upper_chest_girth'] ?? 0.0,
      overarmGirth: json['overarm_girth'] ?? 0.0,
      highHips: json['high_hips'] ?? 0.0,
      alternativeWaistGirth: json['alternative_waist_girth'] ?? 0.0,
      pantWaist: json['pant_waist'] ?? 0.0,
      abdomen: json['abdomen'] ?? 0.0,
      bicep: json['bicep'] ?? 0.0,
      upperBicepGirth: json['upper_bicep_girth'] ?? 0.0,
      upperKneeGirth: json['upper_knee_girth'] ?? 0.0,
      knee: json['knee'] ?? 0.0,
      ankle: json['ankle'] ?? 0.0,
      wrist: json['wrist'] ?? 0.0,
      calf: json['calf'] ?? 0.0,
      thigh: json['thigh'] ?? 0.0,
      midThighGirth: json['mid_thigh_girth'] ?? 0.0,
      neck: json['neck'] ?? 0.0,
      armscyeGirth: json['armscye_girth'] ?? 0.0,
      neckGirth: json['neck_girth'] ?? 0.0,
      forearm: json['forearm'] ?? 0.0,
      elbowGirth: json['elbow_girth'] ?? 0.0,
    );
  }
}

class SideParams {
  final double waistToAnkle;
  final double neckToChest;
  final double chestToWaist;
  final double sideUpperHipLevelToKnee;
  final double sideNeckPointToUpperHip;
  final double shouldersToKnees;
  final double waistDepth;
  final double axillaToWaistSideLength;
  final double neckSideToWaistBackLength;

  SideParams({
    required this.waistToAnkle,
    required this.neckToChest,
    required this.chestToWaist,
    required this.sideUpperHipLevelToKnee,
    required this.sideNeckPointToUpperHip,
    required this.shouldersToKnees,
    required this.waistDepth,
    required this.axillaToWaistSideLength,
    required this.neckSideToWaistBackLength,
  });

  factory SideParams.fromJson(Map<String, dynamic> json) {
    return SideParams(
      waistToAnkle: json['waist_to_ankle'] ?? 0.0,
      neckToChest: json['neck_to_chest'] ?? 0.0,
      chestToWaist: json['chest_to_waist'] ?? 0.0,
      sideUpperHipLevelToKnee: json['side_upper_hip_level_to_knee'] ?? 0.0,
      sideNeckPointToUpperHip: json['side_neck_point_to_upper_hip'] ?? 0.0,
      shouldersToKnees: json['shoulders_to_knees'] ?? 0.0,
      waistDepth: json['waist_depth'] ?? 0.0,
      axillaToWaistSideLength: json['axilla_to_waist_side_length'] ?? 0.0,
      neckSideToWaistBackLength: json['neck_side_to_waist_back_length'] ?? 0.0,
    );
  }
}

class FrontParams {
  final double bodyHeight;
  final double shoulders;
  final double chestTop;
  final double neck;
  final double highHips;
  final double waistToLowHips;
  final double waistToUpperKneeLength;
  final double waistToKnees;
  final double abdomenToUpperKneeLength;
  final double upperKneeToAnkle;
  final double napeToWaistCentreBack;
  final double shoulderToWaist;
  final double sideNeckPointToArmpit;
  final double backNeckHeight;
  final double bustHeight;
  final double hipHeight;
  final double upperHipHeight;
  final double kneeHeight;
  final double outerAnkleHeight;
  final double waistHeight;
  final double inseam;
  final double acrossBackShoulderWidth;
  final double acrossBackWidth;
  final double totalCrotchLength;
  final double waist;
  final double neckLength;
  final double upperArmLength;
  final double lowerArmLength;
  final double backShoulderWidth;
  final double rise;
  final double backNeckToHipLength;

  FrontParams({
    required this.bodyHeight,
    required this.shoulders,
    required this.chestTop,
    required this.neck,
    required this.highHips,
    required this.waistToLowHips,
    required this.waistToUpperKneeLength,
    required this.waistToKnees,
    required this.abdomenToUpperKneeLength,
    required this.upperKneeToAnkle,
    required this.napeToWaistCentreBack,
    required this.shoulderToWaist,
    required this.sideNeckPointToArmpit,
    required this.backNeckHeight,
    required this.bustHeight,
    required this.hipHeight,
    required this.upperHipHeight,
    required this.kneeHeight,
    required this.outerAnkleHeight,
    required this.waistHeight,
    required this.inseam,
    required this.acrossBackShoulderWidth,
    required this.acrossBackWidth,
    required this.totalCrotchLength,
    required this.waist,
    required this.neckLength,
    required this.upperArmLength,
    required this.lowerArmLength,
    required this.backShoulderWidth,
    required this.rise,
    required this.backNeckToHipLength,
  });

  factory FrontParams.fromJson(Map<String, dynamic> json) {
    return FrontParams(
      bodyHeight: json['body_height'] ?? 0.0,
      shoulders: json['shoulders'] ?? 0.0,
      chestTop: json['chest_top'] ?? 0.0,
      neck: json['neck'] ?? 0.0,
      highHips: json['high_hips'] ?? 0.0,
      waistToLowHips: json['waist_to_low_hips'] ?? 0.0,
      waistToUpperKneeLength: json['waist_to_upper_knee_length'] ?? 0.0,
      waistToKnees: json['waist_to_knees'] ?? 0.0,
      abdomenToUpperKneeLength: json['abdomen_to_upper_knee_length'] ?? 0.0,
      upperKneeToAnkle: json['upper_knee_to_ankle'] ?? 0.0,
      napeToWaistCentreBack: json['nape_to_waist_centre_back'] ?? 0.0,
      shoulderToWaist: json['shoulder_to_waist'] ?? 0.0,
      sideNeckPointToArmpit: json['side_neck_point_to_armpit'] ?? 0.0,
      backNeckHeight: json['back_neck_height'] ?? 0.0,
      bustHeight: json['bust_height'] ?? 0.0,
      hipHeight: json['hip_height'] ?? 0.0,
      upperHipHeight: json['upper_hip_height'] ?? 0.0,
      kneeHeight: json['knee_height'] ?? 0.0,
      outerAnkleHeight: json['outer_ankle_height'] ?? 0.0,
      waistHeight: json['waist_height'] ?? 0.0,
      inseam: json['inseam'] ?? 0.0,
      acrossBackShoulderWidth: json['across_back_shoulder_width'] ?? 0.0,
      acrossBackWidth: json['across_back_width'] ?? 0.0,
      totalCrotchLength: json['total_crotch_length'] ?? 0.0,
      waist: json['waist'] ?? 0.0,
      neckLength: json['neck_length'] ?? 0.0,
      upperArmLength: json['upper_arm_length'] ?? 0.0,
      lowerArmLength: json['lower_arm_length'] ?? 0.0,
      backShoulderWidth: json['back_shoulder_width'] ?? 0.0,
      rise: json['rise'] ?? 0.0,
      backNeckToHipLength: json['back_neck_to_hip_length'] ?? 0.0,
    );
  }
}
