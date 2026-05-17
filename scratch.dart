import 'package:flutter/material.dart';

void main() {
  RadioGroup<int>(
    groupValue: 1,
    onChanged: (v) {},
    child: Column(
      children: [
        Radio<int>(value: 1),
      ],
    ),
  );
}
