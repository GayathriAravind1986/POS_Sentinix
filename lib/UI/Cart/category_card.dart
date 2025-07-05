import 'package:flutter/material.dart';
import 'package:simple/Reusable/color.dart';

class CategoryCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.label,
    required this.imagePath,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size.width * 0.1,
        height: size.height * 0.35,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? whiteColor : greyColor.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? blackColor : greyColor.shade300,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(imagePath),
            ),
            SizedBox(height: 6),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
