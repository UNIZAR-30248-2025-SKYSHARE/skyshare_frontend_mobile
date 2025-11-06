import 'package:flutter/material.dart';

class PhotoProfileWidget extends StatelessWidget {
  final String? photoUrl;
  final double radius;

  const PhotoProfileWidget({this.photoUrl, this.radius = 60, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade800,
      child: (photoUrl != null && photoUrl!.isNotEmpty)
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.person,
              size: radius,
              color: Colors.grey.shade400,
            ),
    );
  }
}
