import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 240.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Nền cong
          ClipPath(
            clipper: _CurveClipper(),
            child: Container(
              height: 230.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primary],
                ),
              ),
            ),
          ),
          // Logo với border trực tiếp trên ảnh
          Positioned(
            top: 250.h * 3 / 5 - 20.w, // đặt logo chính giữa đường cong
            child: CircleAvatar(
              radius: 54.w,
              backgroundColor: AppColors.primary, // border màu
              child: CircleAvatar(
                radius: 50.w,
                backgroundImage: AssetImage(
                  isDarkMode
                      ? 'assets/images/logo/blackH.jpg'
                      : 'assets/images/logo/whiteH.jpg',
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

    // Vẽ nửa hình tròn mượt
    path.cubicTo(
      size.width * 0.25,
      size.height, // control point nửa trái
      size.width * 0.75,
      size.height, // control point nửa phải
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
