


import 'package:flutter/material.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class ErrorTextWidget extends StatelessWidget {
  final String? error;

  const ErrorTextWidget({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return error != null
        ? Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        error!,
        style: const TextStyle(color: redColor, fontSize: 12),
      ),
    )
        : const SizedBox.shrink();
  }
}