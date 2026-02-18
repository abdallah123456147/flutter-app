import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationService {
  /// Show a success notification
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show an error notification
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show a warning notification
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.orange[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show an info notification
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.blue[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show a custom notification with full control
  static void showCustom({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.BOTTOM,
    double fontSize = 16.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength:
          duration == const Duration(seconds: 2)
              ? Toast.LENGTH_SHORT
              : Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
