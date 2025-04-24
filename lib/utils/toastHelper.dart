import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      title: Text('Terjadi kesalahan'),
      icon: Icon(Icons.error, color: Colors.red),
      autoCloseDuration: const Duration(seconds: 3),
      description: Text(message),
    );
  }

  static void showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.minimal,
      title: Text('Berhasil'),
      icon: Icon(Icons.check_circle, color: Colors.green),
      autoCloseDuration: const Duration(seconds: 3),
      description: Text(message),
    );
  }

  static void showInfoToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.minimal,
      title: Text('Informasi'),
      icon: Icon(Icons.info, color: Colors.blue),
      autoCloseDuration: const Duration(seconds: 3),
      description: Text(message),
    );
  }
}
