import 'package:flutter/material.dart';

class PhotoProfileWidget extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final ImageProvider? imageProvider;
  
  const PhotoProfileWidget({
    this.photoUrl, 
    this.radius = 60, 
    this.imageProvider, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade800,
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (imageProvider != null) {
      return ClipOval(
        child: Image(
          image: imageProvider!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        ),
      );
    }
    
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            
            return Center(
              child: SizedBox(
                width: radius * 0.8,
                height: radius * 0.8,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.shade400,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Icon(
      Icons.person,
      size: radius,
      color: Colors.grey.shade400,
    );
  }
}