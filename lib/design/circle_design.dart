import 'package:flutter/material.dart';

Widget circleContainer(String day, {required bool isDone}) {
  return Container(
    width: 32,
    height: 32,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: isDone ? const Color(0xFF2D3436) : Colors.white,
      shape: BoxShape.circle,
      border: isDone ? null : Border.all(color: const Color(0xFFDFE6E9), width: 1.5),
    ),
    child: Center(
      child: Text(
        day,
        style: TextStyle(
          color: isDone ? Colors.white : const Color(0xFFB2BEC3),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}