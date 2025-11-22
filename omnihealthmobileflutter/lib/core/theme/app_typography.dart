import 'package:flutter/material.dart';

class AppTypography {
  // Font Families
  static const String headingBold = 'Orbitron';
  static const String headingRegular = 'Orbitron';
  static const String bodyBold = 'Montserrat';
  static const String bodyRegular = 'Montserrat';
  static const String bodyItalic = 'Montserrat';

  // Font Sizes
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLg = 20.0;
  static const double fontSizeXl = 24.0;
  static const double fontSize2Xl = 32.0;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // Text Styles - Headings (Orbitron)
  static TextStyle headingBoldStyle({
    double fontSize = fontSizeBase,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: headingBold,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      height: height,
    );
  }

  static TextStyle headingRegularStyle({
    double fontSize = fontSizeBase,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: headingRegular,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
      height: height,
    );
  }

  // Text Styles - Body (Montserrat)
  static TextStyle bodyBoldStyle({
    double fontSize = fontSizeBase,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: bodyBold,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      height: height,
    );
  }

  static TextStyle bodyRegularStyle({
    double fontSize = fontSizeBase,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: bodyRegular,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
      height: height,
    );
  }

  static TextStyle bodyItalicStyle({
    double fontSize = fontSizeBase,
    Color color = Colors.black,
    double? height,
  }) {
    return TextStyle(
      fontFamily: bodyItalic,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: color,
      height: height,
    );
  }

  // Predefined Text Styles
  static TextStyle h1 = headingBoldStyle(
    fontSize: fontSize2Xl,
    height: lineHeightTight,
  );
  static TextStyle h2 = headingBoldStyle(
    fontSize: fontSizeXl,
    height: lineHeightTight,
  );
  static TextStyle h3 = headingBoldStyle(
    fontSize: fontSizeLg,
    height: lineHeightNormal,
  );
  static TextStyle h4 = headingRegularStyle(
    fontSize: fontSizeLg,
    height: lineHeightNormal,
  );

  static TextStyle bodyLarge = bodyRegularStyle(
    fontSize: fontSizeLg,
    height: lineHeightNormal,
  );
  static TextStyle bodyMedium = bodyRegularStyle(
    fontSize: fontSizeBase,
    height: lineHeightNormal,
  );
  static TextStyle bodySmall = bodyRegularStyle(
    fontSize: fontSizeSm,
    height: lineHeightNormal,
  );
  static TextStyle caption = bodyRegularStyle(
    fontSize: fontSizeXs,
    height: lineHeightNormal,
  );
}
