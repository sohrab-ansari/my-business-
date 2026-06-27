import 'package:flutter/material.dart';

class UiHelpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is Exception) return error.toString().replaceFirst('Exception: ', '');
    return error.toString();
  }
}