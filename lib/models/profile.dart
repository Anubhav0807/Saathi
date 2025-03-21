import 'package:flutter/material.dart';

class Profile {
  const Profile({
    required this.name,
    required this.regNo,
    required this.gender,
    this.pfp,
  });

  final String name;
  final String regNo;
  final String gender;
  final Image? pfp;
}
