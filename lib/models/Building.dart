import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Building{
  final String uid;
  final String name;
  final String architects;
  final String address;
  final String description;
  final GeoPoint location;
  final bool approved;
  final List<dynamic> images;
  final List<dynamic> extraData;
  final String publishedBy;

  const Building({
    this.uid,
    this.extraData,
    @required this.name,
    @required this.architects,
    @required this.address,
    @required this.description,
    @required this.location,
    this.approved: false,
    @required this.images,
    @required this.publishedBy,
  });
}
