import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class DateBlocageWidget extends StatefulWidget {
  final String title;
  final String? initialValue;
  final Function(String?) onDateSelected;

  const DateBlocageWidget({
    super.key,
    required this.title,
    this.initialValue,
    required this.onDateSelected,
  });

  @override
  State<DateBlocageWidget> createState() => _DateBlocageWidgetState();
}

class _DateBlocageWidgetState extends State<DateBlocageWidget> {
  String? _value;

  @override
  void initState() {
    super.initState();
    _loadInitialDate();
  }

  Future<void> _loadInitialDate() async {
    final contactState = context.read<ContactCubit>().state;
    final contact = contactState.selectedContact;
    if (contact?.dateOfLock?.isNotEmpty ?? false){
      setState(() {
        _value = contact!.dateOfLock;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Adaptive.h(0.5),
        horizontal: Adaptive.w(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: Adaptive.sp(15),
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _value != null && _value!.isNotEmpty
                    ? DateFormat('dd/MM/yyyy').parse(_value!)
                    : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                setState(() {
                  _value = formattedDate;
                });
                widget.onDateSelected(_value);
              }
            },
            child: Text(
              _value ?? "Sélectionner une date",
              style: TextStyle(
                fontSize: Adaptive.sp(15),
                color: _value != null ? redColor : greyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}