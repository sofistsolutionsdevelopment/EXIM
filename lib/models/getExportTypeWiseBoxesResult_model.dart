// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

GetExportTypeWiseBoxesResultModel getExportTypeWiseBoxesResultModelFromJson(String str) => GetExportTypeWiseBoxesResultModel.fromJson(json.decode(str));

String getExportTypeWiseBoxesResultModelToJson(GetExportTypeWiseBoxesResultModel data) => json.encode(data.toJson());

class GetExportTypeWiseBoxesResultModel {

  int ExportType_value;
  String ExportType;
  int BoxCount;


  GetExportTypeWiseBoxesResultModel({
    this.ExportType_value,
    this.ExportType,
    this.BoxCount,
  });

  factory GetExportTypeWiseBoxesResultModel.fromJson(Map<String, dynamic> json) => GetExportTypeWiseBoxesResultModel(
    ExportType_value: json["ExportType_value"],
    ExportType: json["ExportType"],
    BoxCount: json["BoxCount"],
  );

  Map<String, dynamic> toJson() => {
    "ExportType_value": ExportType_value,
    "ExportType": ExportType,
    "BoxCount": BoxCount
  };
}
