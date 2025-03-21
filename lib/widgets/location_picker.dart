import 'package:flutter/material.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({
    super.key,
    this.hint,
    this.validator,
    required this.onChanged,
  });

  final Widget? hint;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final location = {
      'VIT Chennai': Icons.business_rounded,
      'Airport': Icons.local_airport_rounded,
      'Railway': Icons.train_rounded,
      'Bus Stop': Icons.bus_alert,
    };

    return DropdownButtonFormField(
      hint: hint,
      items: location.keys
          .map(
            (element) => DropdownMenuItem(
              value: element,
              child: Row(
                children: [
                  SizedBox(
                    width: 128,
                    child: Text(element),
                  ),
                  Icon(location[element]),
                ],
              ),
            ),
          )
          .toList(),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
