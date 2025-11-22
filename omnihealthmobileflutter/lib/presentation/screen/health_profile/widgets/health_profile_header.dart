import 'package:flutter/material.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/health_profile_home_screen.dart';

class HealthProfileHeaderWidget extends StatelessWidget {
  final bool hasHealthData;

  const HealthProfileHeaderWidget({
    Key? key,
    this.hasHealthData = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasHealthData 
          ? const HealthProfileHomeScreen()
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to add health info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthProfileHomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Health Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }
}