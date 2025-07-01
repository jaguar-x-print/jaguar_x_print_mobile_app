import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class EntretienDropdown extends StatelessWidget {
  final String? label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const EntretienDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Adaptive.h(1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label ?? '',
              style: TextStyle(
                fontSize: Adaptive.sp(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: Adaptive.w(0.3)),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: Adaptive.w(30),
                height: Adaptive.h(4.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    border: Border.all(
                      color: enabled ? greyColor : blackColor,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: enabled ? value : null,
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(fontSize: Adaptive.sp(13)),
                          textAlign: TextAlign.left,
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return items.map<Widget>((String item) {
                        return Text(
                          item,
                          style: TextStyle(
                            color: enabled ? blackColor : greyColor,
                            fontWeight: FontWeight.bold,
                            fontSize: Adaptive.sp(13),
                          ),
                        );
                      }).toList();
                    },
                    onChanged: enabled ? onChanged : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: enabled ? whiteColor : whiteColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Adaptive.w(4),
                        vertical: Adaptive.h(1),
                      ),
                    ),
                    style: TextStyle(
                      color: enabled ? blackColor : greyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Adaptive.sp(13),
                    ),
                    dropdownColor: whiteColor,
                    isExpanded: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}