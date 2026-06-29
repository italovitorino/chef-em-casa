import 'package:flutter/material.dart';
import '../theme.dart';

class ChefHomeScreen extends StatelessWidget {
  const ChefHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Text('Chef Home', style: AppText.cormorant(fontSize: 32)),
      ),
    );
  }
}
