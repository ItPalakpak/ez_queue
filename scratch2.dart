import 'package:flutter/material.dart';

void main() {
  RadioGroup<int>(
    groupValue: 1,
    onChanged: (v) {},
    child: Column(
      children: [
        RadioListTile<int>(
          value: 1,
          title: Text('One'),
        ),
        RadioListTile<int>(
          value: 2,
          title: Text('Two'),
          enabled: false,
        ),
      ],
    ),
  );
}
