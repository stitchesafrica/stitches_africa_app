class UserMeasurementModel {
  final VolumeParams volumeParams;
  final SideParams sideParams;
  final FrontParams frontParams;

  UserMeasurementModel({
    required this.volumeParams,
    required this.sideParams,
    required this.frontParams,
  });

  factory UserMeasurementModel.fromDocument(Map<String, dynamic> doc) {
    return UserMeasurementModel(
      volumeParams: VolumeParams.fromDocument(doc['volume_params'] ?? {}),
      sideParams: SideParams.fromDocument(doc['side_params'] ?? {}),
      frontParams: FrontParams.fromDocument(doc['front_params'] ?? {}),
    );
  }
}

class VolumeParams {
  final double chest;
  final double underBustGirth;
  final double upperChestGirth;
  final double overarmGirth;
  final double waist;
  final double alternativeWaistGirth;
  final double highHips;
  final double lowHips;
  final double waistGreen;
  final double waistGray;
  final double pantWaist;
  final double bicep;
  final double upperBicepGirth;
  final double upperKneeGirth;
  final double knee;
  final double ankle;
  final double wrist;
  final double calf;
  final double thigh;
  final double thighOneInchBelowCrotch;
  final double midThighGirth;
  final double neck;
  final double abdomen;
  final double armscyeGirth;
  final double neckGirth;
  final double neckGirthRelaxed;
  final double forearm;
  final double elbowGirth;
  final String? bodyType;
  final String? bodyModel;

  VolumeParams({
    required this.chest,
    required this.underBustGirth,
    required this.upperChestGirth,
    required this.overarmGirth,
    required this.waist,
    required this.alternativeWaistGirth,
    required this.highHips,
    required this.lowHips,
    required this.waistGreen,
    required this.waistGray,
    required this.pantWaist,
    required this.bicep,
    required this.upperBicepGirth,
    required this.upperKneeGirth,
    required this.knee,
    required this.ankle,
    required this.wrist,
    required this.calf,
    required this.thigh,
    required this.thighOneInchBelowCrotch,
    required this.midThighGirth,
    required this.neck,
    required this.abdomen,
    required this.armscyeGirth,
    required this.neckGirth,
    required this.neckGirthRelaxed,
    required this.forearm,
    required this.elbowGirth,
    this.bodyType,
    this.bodyModel,
  });

  factory VolumeParams.fromDocument(Map<String, dynamic> doc) {
    return VolumeParams(
      chest: doc['chest'] ?? 0.0,
      underBustGirth: doc['under_bust_girth'] ?? 0.0,
      upperChestGirth: doc['upper_chest_girth'] ?? 0.0,
      overarmGirth: doc['overarm_girth'] ?? 0.0,
      waist: doc['waist'] ?? 0.0,
      alternativeWaistGirth: doc['alternative_waist_girth'] ?? 0.0,
      highHips: doc['high_hips'] ?? 0.0,
      lowHips: doc['low_hips'] ?? 0.0,
      waistGreen: doc['waist_green'] ?? 0.0,
      waistGray: doc['waist_gray'] ?? 0.0,
      pantWaist: doc['pant_waist'] ?? 0.0,
      bicep: doc['bicep'] ?? 0.0,
      upperBicepGirth: doc['upper_bicep_girth'] ?? 0.0,
      upperKneeGirth: doc['upper_knee_girth'] ?? 0.0,
      knee: doc['knee'] ?? 0.0,
      ankle: doc['ankle'] ?? 0.0,
      wrist: doc['wrist'] ?? 0.0,
      calf: doc['calf'] ?? 0.0,
      thigh: doc['thigh'] ?? 0.0,
      thighOneInchBelowCrotch: doc['thigh_1_inch_below_crotch'] ?? 0.0,
      midThighGirth: doc['mid_thigh_girth'] ?? 0.0,
      neck: doc['neck'] ?? 0.0,
      abdomen: doc['abdomen'] ?? 0.0,
      armscyeGirth: doc['armscye_girth'] ?? 0.0,
      neckGirth: doc['neck_girth'] ?? 0.0,
      neckGirthRelaxed: doc['neck_girth_relaxed'] ?? 0.0,
      forearm: doc['forearm'] ?? 0.0,
      elbowGirth: doc['elbow_girth'] ?? 0.0,
      bodyType: doc['body_type'],
      bodyModel: doc['body_model'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'chest': chest,
      'under_bust_girth': underBustGirth,
      'upper_chest_girth': upperChestGirth,
      'overarm_girth': overarmGirth,
      'waist': waist,
      'alternative_waist_girth': alternativeWaistGirth,
      'high_hips': highHips,
      'low_hips': lowHips,
      'waist_green': waistGreen,
      'waist_gray': waistGray,
      'pant_waist': pantWaist,
      'bicep': bicep,
      'upper_bicep_girth': upperBicepGirth,
      'upper_knee_girth': upperKneeGirth,
      'knee': knee,
      'ankle': ankle,
      'wrist': wrist,
      'calf': calf,
      'thigh': thigh,
      'thigh_1_inch_below_crotch': thighOneInchBelowCrotch,
      'mid_thigh_girth': midThighGirth,
      'neck': neck,
      'abdomen': abdomen,
      'armscye_girth': armscyeGirth,
      'neck_girth': neckGirth,
      'neck_girth_relaxed': neckGirthRelaxed,
      'forearm': forearm,
      'elbow_girth': elbowGirth,
      'body_type': bodyType,
      'body_model': bodyModel,
    };
  }
}

class SideParams {
  final double bodyAreaPercentage;
  final double sideUpperHipLevelToKnee;
  final double sideNeckPointToUpperHip;
  final double neckToChest;
  final double chestToWaist;
  final double waistToAnkle;
  final double shouldersToKnees;
  final double waistDepth;
  final double axillaToWaistSideLength;
  final double neckSideToWaistBackLength;

  SideParams({
    required this.bodyAreaPercentage,
    required this.sideUpperHipLevelToKnee,
    required this.sideNeckPointToUpperHip,
    required this.neckToChest,
    required this.chestToWaist,
    required this.waistToAnkle,
    required this.shouldersToKnees,
    required this.waistDepth,
    required this.axillaToWaistSideLength,
    required this.neckSideToWaistBackLength,
  });

  factory SideParams.fromDocument(Map<String, dynamic> doc) {
    return SideParams(
      bodyAreaPercentage: doc['body_area_percentage'] ?? 0.0,
      sideUpperHipLevelToKnee: doc['side_upper_hip_level_to_knee'] ?? 0.0,
      sideNeckPointToUpperHip: doc['side_neck_point_to_upper_hip'] ?? 0.0,
      neckToChest: doc['neck_to_chest'] ?? 0.0,
      chestToWaist: doc['chest_to_waist'] ?? 0.0,
      waistToAnkle: doc['waist_to_ankle'] ?? 0.0,
      shouldersToKnees: doc['shoulders_to_knees'] ?? 0.0,
      waistDepth: doc['waist_depth'] ?? 0.0,
      axillaToWaistSideLength: doc['axilla_to_waist_side_length'] ?? 0.0,
      neckSideToWaistBackLength: doc['neck_side_to_waist_back_length'] ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'body_area_percentage': bodyAreaPercentage,
      'side_upper_hip_level_to_knee': sideUpperHipLevelToKnee,
      'side_neck_point_to_upper_hip': sideNeckPointToUpperHip,
      'neck_to_chest': neckToChest,
      'chest_to_waist': chestToWaist,
      'waist_to_ankle': waistToAnkle,
      'shoulders_to_knees': shouldersToKnees,
      'waist_depth': waistDepth,
      'axilla_to_waist_side_length': axillaToWaistSideLength,
      'neck_side_to_waist_back_length': neckSideToWaistBackLength,
    };
  }
}

class FrontParams {
  final double bodyAreaPercentage;
  final double bodyHeight;
  final double outseam;
  final double outseamFromUpperHipLevel;
  final double inseam;
  final double insideLegLengthToThe1InchAboveTheFloor;
  final double insideCrotchLengthToMidThigh;
  final double insideCrotchLengthToKnee;
  final double insideCrotchLengthToCalf;
  final double crotchLength;
  final double sleeveLength;
  final double underarmLength;
  final double backNeckPointToWristLength;
  final double backNeckPointToWristLength15Inch;
  final double highHips;
  final double shoulders;
  final double chestTop;
  final double shoulderLength;
  final double shoulderSlope;
  final double neck;
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
  final double inseamFromCrotchToAnkle;
  final double inseamFromCrotchToFloor;
  final double newJacketLength;
  final double sideNeckPointToThigh;

  FrontParams({
    required this.bodyAreaPercentage,
    required this.bodyHeight,
    required this.outseam,
    required this.outseamFromUpperHipLevel,
    required this.inseam,
    required this.insideLegLengthToThe1InchAboveTheFloor,
    required this.insideCrotchLengthToMidThigh,
    required this.insideCrotchLengthToKnee,
    required this.insideCrotchLengthToCalf,
    required this.crotchLength,
    required this.sleeveLength,
    required this.underarmLength,
    required this.backNeckPointToWristLength,
    required this.backNeckPointToWristLength15Inch,
    required this.highHips,
    required this.shoulders,
    required this.chestTop,
    required this.shoulderLength,
    required this.shoulderSlope,
    required this.neck,
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
    required this.inseamFromCrotchToAnkle,
    required this.inseamFromCrotchToFloor,
    required this.newJacketLength,
    required this.sideNeckPointToThigh,
  });

  factory FrontParams.fromDocument(Map<String, dynamic> doc) {
    return FrontParams(
      bodyAreaPercentage: doc['body_area_percentage'] ?? 0.0,
      bodyHeight: doc['body_height'] ?? 0.0,
      outseam: doc['outseam'] ?? 0.0,
      outseamFromUpperHipLevel: doc['outseam_from_upper_hip_level'] ?? 0.0,
      inseam: doc['inseam'] ?? 0.0,
      insideLegLengthToThe1InchAboveTheFloor:
          doc['inside_leg_length_to_the_1_inch_above_the_floor'] ?? 0.0,
      insideCrotchLengthToMidThigh:
          doc['inside_crotch_length_to_mid_thigh'] ?? 0.0,
      insideCrotchLengthToKnee: doc['inside_crotch_length_to_knee'] ?? 0.0,
      insideCrotchLengthToCalf: doc['inside_crotch_length_to_calf'] ?? 0.0,
      crotchLength: doc['crotch_length'] ?? 0.0,
      sleeveLength: doc['sleeve_length'] ?? 0.0,
      underarmLength: doc['underarm_length'] ?? 0.0,
      backNeckPointToWristLength: doc['back_neck_point_to_wrist_length'] ?? 0.0,
      backNeckPointToWristLength15Inch:
          doc['back_neck_point_to_wrist_length_1_5_inch'] ?? 0.0,
      highHips: doc['high_hips'] ?? 0.0,
      shoulders: doc['shoulders'] ?? 0.0,
      chestTop: doc['chest_top'] ?? 0.0,
      shoulderLength: doc['shoulder_length'] ?? 0.0,
      shoulderSlope: doc['shoulder_slope'] ?? 0.0,
      neck: doc['neck'] ?? 0.0,
      waistToLowHips: doc['waist_to_low_hips'] ?? 0.0,
      waistToUpperKneeLength: doc['waist_to_upper_knee_length'] ?? 0.0,
      waistToKnees: doc['waist_to_knees'] ?? 0.0,
      abdomenToUpperKneeLength: doc['abdomen_to_upper_knee_length'] ?? 0.0,
      upperKneeToAnkle: doc['upper_knee_to_ankle'] ?? 0.0,
      napeToWaistCentreBack: doc['nape_to_waist_centre_back'] ?? 0.0,
      shoulderToWaist: doc['shoulder_to_waist'] ?? 0.0,
      sideNeckPointToArmpit: doc['side_neck_point_to_armpit'] ?? 0.0,
      backNeckHeight: doc['back_neck_height'] ?? 0.0,
      bustHeight: doc['bust_height'] ?? 0.0,
      hipHeight: doc['hip_height'] ?? 0.0,
      upperHipHeight: doc['upper_hip_height'] ?? 0.0,
      kneeHeight: doc['knee_height'] ?? 0.0,
      outerAnkleHeight: doc['outer_ankle_height'] ?? 0.0,
      waistHeight: doc['waist_height'] ?? 0.0,
      inseamFromCrotchToAnkle: doc['inseam_from_crotch_to_ankle'] ?? 0.0,
      inseamFromCrotchToFloor: doc['inseam_from_crotch_to_floor'] ?? 0.0,
      newJacketLength: doc['new_jacket_length'] ?? 0.0,
      sideNeckPointToThigh: doc['side_neck_point_to_thigh'] ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'body_area_percentage': bodyAreaPercentage,
      'body_height': bodyHeight,
      'outseam': outseam,
      'outseam_from_upper_hip_level': outseamFromUpperHipLevel,
      'inseam': inseam,
      'inside_leg_length_to_the_1_inch_above_the_floor':
          insideLegLengthToThe1InchAboveTheFloor,
      'inside_crotch_length_to_mid_thigh': insideCrotchLengthToMidThigh,
      'inside_crotch_length_to_knee': insideCrotchLengthToKnee,
      'inside_crotch_length_to_calf': insideCrotchLengthToCalf,
      'crotch_length': crotchLength,
      'sleeve_length': sleeveLength,
      'underarm_length': underarmLength,
      'back_neck_point_to_wrist_length': backNeckPointToWristLength,
      'back_neck_point_to_wrist_length_1_5_inch':
          backNeckPointToWristLength15Inch,
      'high_hips': highHips,
      'shoulders': shoulders,
      'chest_top': chestTop,
      'shoulder_length': shoulderLength,
      'shoulder_slope': shoulderSlope,
      'neck': neck,
      'waist_to_low_hips': waistToLowHips,
      'waist_to_upper_knee_length': waistToUpperKneeLength,
      'waist_to_knees': waistToKnees,
      'abdomen_to_upper_knee_length': abdomenToUpperKneeLength,
      'upper_knee_to_ankle': upperKneeToAnkle,
      'nape_to_waist_centre_back': napeToWaistCentreBack,
      'shoulder_to_waist': shoulderToWaist,
      'side_neck_point_to_armpit': sideNeckPointToArmpit,
      'back_neck_height': backNeckHeight,
      'bust_height': bustHeight,
      'hip_height': hipHeight,
      'upper_hip_height': upperHipHeight,
      'knee_height': kneeHeight,
      'outer_ankle_height': outerAnkleHeight,
      'waist_height': waistHeight,
      'inseam_from_crotch_to_ankle': inseamFromCrotchToAnkle,
      'inseam_from_crotch_to_floor': inseamFromCrotchToFloor,
      'new_jacket_length': newJacketLength,
      'side_neck_point_to_thigh': sideNeckPointToThigh,
    };
  }
}
