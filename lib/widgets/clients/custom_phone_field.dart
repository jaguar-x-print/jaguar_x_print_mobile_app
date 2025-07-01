import 'package:country_code_picker_plus/country_code_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    // Retirer tous les caractères non numériques
    final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');

    // Calculer combien de chiffres il y avait avant la position du curseur
    int digitIndexBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.baseOffset && i < newText.length; i++) {
      if (RegExp(r'\d').hasMatch(newText[i])) {
        digitIndexBeforeCursor++;
      }
    }

    // Formater les chiffres avec des espaces tous les 3 chiffres
    final buffer = StringBuffer();
    int newCursorPosition = 0;
    int digitCount = 0;

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
        if (digitCount < digitIndexBeforeCursor) {
          newCursorPosition++;
        }
      }

      buffer.write(digitsOnly[i]);

      if (digitCount < digitIndexBeforeCursor) {
        newCursorPosition++;
      }

      digitCount++;
    }

    final formatted = buffer.toString();

    // Corriger si le curseur dépasse
    newCursorPosition = newCursorPosition.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

class CustomPhoneField extends StatefulWidget {
  const CustomPhoneField({
    super.key,
    this.onTap,
    required this.focus,
    required this.hint,
    this.controller,
    required this.onChange,
    this.correct,
    this.prefixIcon,
    this.suffixIcon,
    this.initialCountryCode = 'CM',
    this.onCountryChanged,
  });

  final bool focus;
  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final Function(String, String) onChange;
  final bool? correct;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String initialCountryCode;
  final Function(Country)? onCountryChanged;

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  String _countryCode = '';
  String _dialCode = '';

  @override
  void initState() {
    super.initState();
    _countryCode = widget.initialCountryCode;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: widget.focus
            ? const LinearGradient(
                colors: [
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  firstColor,
                  whiteColor,
                  whiteColor,
                ],
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CountryCodePicker(
              onChanged: (Country country) {
                setState(() {
                  _countryCode = country.code;
                  _dialCode = country.dialCode ?? '';
                });
                widget.onCountryChanged?.call(country);
              },
              onInit: (Country? country) {
                _dialCode = country?.dialCode ?? '';
                _countryCode = country?.code ?? widget.initialCountryCode;
              },
              initialSelection: widget.initialCountryCode,
              favorite: [_countryCode],
              showFlag: true,
              showFlagDialog: true,
              alignLeft: false,
              boxDecoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
              flagDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              textStyle: const TextStyle(
                color: whiteColor,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: TextField(
              controller: widget.controller,
              onTap: widget.onTap,
              inputFormatters: [
                PhoneNumberFormatter(), // Utilisation unique du formateur
              ],
              decoration: InputDecoration(
                filled: true,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: firstColor,
                        size: Adaptive.sp(20),
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? Icon(
                        widget.suffixIcon,
                        color: firstColor,
                        size: Adaptive.sp(20),
                      )
                    : null,
                fillColor: whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Adaptive.w(4),
                  vertical: Adaptive.h(1),
                ),
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.normal,
                  fontSize: Adaptive.sp(13),
                ),
              ),
              style: const TextStyle(
                color: blackColor,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => widget.onChange(_dialCode, value),
            ),
          ),
        ],
      ),
    );
  }
}
