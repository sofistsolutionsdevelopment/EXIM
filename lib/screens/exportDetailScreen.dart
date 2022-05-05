import 'package:flutter/material.dart';


class ExportDetailPage extends StatefulWidget {
  final Function onPressed;
  final String exportType_value;


  ExportDetailPage({this.onPressed, this.exportType_value});
  @override
  _ExportDetailPageState createState() => _ExportDetailPageState();
}

class _ExportDetailPageState extends State<ExportDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("EXPORT DETAIL PAGE : ${widget.exportType_value}")),
    );
  }
}
