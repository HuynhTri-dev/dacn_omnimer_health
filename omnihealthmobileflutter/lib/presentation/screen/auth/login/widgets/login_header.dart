import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 280.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Nền gradient với hiệu ứng đẹp hơn
          ClipPath(
            clipper: _CurveClipper(),
            child: Container(
              height: 260.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                    primaryColor.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles - top right
                  Positioned(
                    top: -30.h,
                    right: -30.w,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Decorative circles - top left
                  Positioned(
                    top: 40.h,
                    left: -20.w,
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // Decorative circles - middle right
                  Positioned(
                    top: 100.h,
                    right: 30.w,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                  // Small decorative dots
                  Positioned(
                    top: 60.h,
                    right: 80.w,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120.h,
                    left: 60.w,
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Logo với shadow và border đẹp hơn
          Positioned(
            top: 260.h * 3 / 5 - 30.w,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60.w,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56.w,
                  backgroundColor: primaryColor,
                  child: CircleAvatar(
                    radius: 52.w,
                    backgroundImage: AssetImage(
                      isDarkMode
                          ? 'assets/images/logo/blackH.jpg'
                          : 'assets/images/logo/whiteH.jpg',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Bắt đầu từ góc trên trái
    path.moveTo(0, 0);

    // Đi xuống điểm bắt đầu cong
    path.lineTo(0, size.height * 2 / 5);

    // Vẽ đường cong mượt mà hơn với nhiều control points
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.95, // control point nửa trái
      size.width * 0.75,
      size.height * 0.95, // control point nửa phải
      size.width,
      size.height * 2 / 5, // điểm kết thúc
    );

    // Đi lên góc trên phải
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
