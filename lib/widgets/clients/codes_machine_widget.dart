import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class CodesMachineWidget extends StatelessWidget {
  const CodesMachineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactCubit, ContactState>(
      builder: (context, state) {
        List<String> codesMachine = state.selectedContact?.codesMachine ?? [];
        return Column(
          children: [
            Text(
              "Code Machine",
              style: TextStyle(
                fontSize: Adaptive.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Adaptive.h(0.8)),
            ...codesMachine.map(
                  (code) => Container(
                padding: EdgeInsets.symmetric(vertical: Adaptive.h(0.00001)),
                width: Adaptive.w(80),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          code,
                          style: TextStyle(
                            color: blackColor,
                            backgroundColor: blueColor,
                            fontSize: Adaptive.sp(18),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ),
                    IconButton( // Copy Icon
                      icon: Icon(
                        Icons.copy_rounded,
                        size: Adaptive.sp(16),
                        color: firstColor,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copié !')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (codesMachine.length < 3)
              TextButton.icon(
                onPressed: () => _showCodeMachineDialog(context),
                icon: Container(
                  decoration: const BoxDecoration(
                    color: blueColor,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(Adaptive.w(1)),
                  child: Icon(
                    Icons.add_rounded,
                    color: whiteColor,
                    size: Adaptive.sp(20),
                  ),
                ),
                label: Text(
                  "Ajouter un code",
                  style: TextStyle(
                    fontSize: Adaptive.sp(16),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showCodeMachineDialog(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ajouter un Code Machine", style: TextStyle(fontSize: Adaptive.sp(18))),
          content: InputField(
            controller: codeController,
            onTap: () {},
            focus: true,
            backColor: whiteColor,
            textColor: blackColor,
            hint: 'Saisissez le code machine',
            prefixIcon: Icons.numbers_rounded,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annuler", style: TextStyle(fontSize: Adaptive.sp(16))),
            ),
            TextButton(
              onPressed: () {
                if (codeController.text.isNotEmpty) {
                  context.read<ContactCubit>().addCodeMachine(codeController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Ajouter",
                style: TextStyle(
                  fontSize: Adaptive.sp(16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}