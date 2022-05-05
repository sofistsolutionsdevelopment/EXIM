// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);
/*
import 'dart:convert';
import 'checkTodaysSelfDeclarationResult_model.dart';

CheckTodaysSelfDeclarationDataModel checkTodaysSelfDeclarationDataModelFromJson(String str) => CheckTodaysSelfDeclarationDataModel.fromJson(json.decode(str));

String checkTodaysSelfDeclarationDataModelToJson(CheckTodaysSelfDeclarationDataModel data) => json.encode(data.toJson());


class CheckTodaysSelfDeclarationDataModel {

  List<CheckTodaysSelfDeclarationResultModel> Data;


  CheckTodaysSelfDeclarationDataModel({ this.Data});

  CheckTodaysSelfDeclarationDataModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      Data = new List<CheckTodaysSelfDeclarationResultModel>();
      json['Data'].forEach((v) {
        Data.add(new CheckTodaysSelfDeclarationResultModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.Data != null) {
      data['Data'] = this.Data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
*/


import 'dart:convert';
import 'getBoxDetailsResult_model.dart';
import 'getDDLFailureReasonsResult_model.dart';

GetDDLFailureReasonsDataModel getDDLFailureReasonsDataModelFromJson(String str) => GetDDLFailureReasonsDataModel.fromJson(json.decode(str));

String getDDLFailureReasonsDataModelToJson(GetDDLFailureReasonsDataModel data) => json.encode(data.toJson());


class GetDDLFailureReasonsDataModel {

  List<GetDDLFailureReasonsResultModel> Data;


  GetDDLFailureReasonsDataModel({ this.Data});

  GetDDLFailureReasonsDataModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      Data = new List<GetDDLFailureReasonsResultModel>();
      json['Data'].forEach((v) {
        Data.add(new GetDDLFailureReasonsResultModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.Data != null) {
      data['Data'] = this.Data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


