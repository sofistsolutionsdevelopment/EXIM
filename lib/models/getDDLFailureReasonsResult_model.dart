// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

GetDDLFailureReasonsResultModel getDDLFailureReasonsResultModelFromJson(String str) => GetDDLFailureReasonsResultModel.fromJson(json.decode(str));

String getDDLFailureReasonsResultModelToJson(GetDDLFailureReasonsResultModel data) => json.encode(data.toJson());

class GetDDLFailureReasonsResultModel {


  int Code;
  String FailureReason;
  String FailShrotCode;
  bool IsChecked;

  GetDDLFailureReasonsResultModel({
    this.Code,
    this.FailureReason,
    this.FailShrotCode,
    this.IsChecked,
  });

  factory GetDDLFailureReasonsResultModel.fromJson(Map<String, dynamic> json) =>GetDDLFailureReasonsResultModel(
    Code: json["Code"],
    FailureReason: json["FailureReason"],
    FailShrotCode: json["FailShrotCode"],
    IsChecked: json["IsChecked"] = false,
  );

  Map<String, dynamic> toJson() => {
    "Code": Code,
    "FailureReason": FailureReason,
    "FailShrotCode": FailShrotCode,
    "IsChecked": IsChecked,
  };
}
