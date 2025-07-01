import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/widgets/clients/collaborators/contact_link_widget.dart';
import 'package:jaguar_x_print/widgets/clients/custom_phone_field.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class CollaboratorCard extends StatefulWidget {
  const CollaboratorCard({super.key, required this.collaborator});
  final Map<String, dynamic> collaborator;

  @override
  State<CollaboratorCard> createState() => _CollaboratorCardState();
}

class _CollaboratorCardState extends State<CollaboratorCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _jobTitleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.collaborator['name'] ?? "",
    );
    _phoneController = TextEditingController(
      text: widget.collaborator['phone'] ?? "",
    );
    _whatsappController = TextEditingController(
      text: widget.collaborator['whatsapp'] ?? "",
    );
    _jobTitleController = TextEditingController(
      text: widget.collaborator['jobTitle'] ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  String _formatWithSpaces(String value) {
    if (value.length <= 3) {
      return value;
    }

    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(' ');
      }
    }

    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 2.5.h,
              vertical: 0.8.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nom: ${widget.collaborator['name'] ?? ""}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Adaptive.sp(14),
                  ),
                ),
                SizedBox(height: 0.5.h),
                ContactLink(
                  label: "Téléphone: ",
                  phoneNumber: widget.collaborator['phone'],
                ),
                SizedBox(height: 0.5.h),
                ContactLink(
                  label: "WhatsApp: ",
                  phoneNumber: widget.collaborator['whatsapp'],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Poste: ${widget.collaborator['jobTitle'] ?? ""}",
                  style: TextStyle(fontSize: Adaptive.sp(14)),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  _showConfirmationDialog(context, widget.collaborator);
                },
                icon: Icon(
                  Icons.mode_edit_rounded,
                  size: Adaptive.sp(25),
                  color: green2Color,
                ),
              ),
              IconButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
                icon: Icon(
                  Icons.delete_forever_rounded,
                  size: Adaptive.sp(25),
                  color: redColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> collaborator,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modifier les informations"),
          content: const Text(
            "Voulez-vous vraiment modifier les informations de ce collaborateur ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Non"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditBottomSheet(context, collaborator);
              },
              child: const Text("Oui"),
            ),
          ],
        );
      },
    );
  }

  void _showEditBottomSheet(
    BuildContext context,
    Map<String, dynamic> collaborator,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(1.h),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(29),
                        color: redColor,
                      ),
                      height: 0.5.h,
                      width: 15.w,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Modifier un collaborateur",
                    style: TextStyle(
                      fontSize: Adaptive.sp(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.all(1.6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nom collaborateur",
                        style: TextStyle(fontSize: Adaptive.sp(12)),
                      ),
                      InputField(
                        controller: _nameController,
                        hint: "Nom",
                        onTap: () {},
                        backColor: whiteColor,
                        focus: true,
                        textColor: blackColor,
                        prefixIcon: Icons.person_2_rounded,
                      ),
                      SizedBox(height: 1.6.h),
                      Text(
                        "Numéro de téléphone",
                        style: TextStyle(fontSize: Adaptive.sp(12)),
                      ),
                      CustomPhoneField(
                        focus: true,
                        hint: "xxx....",
                        initialCountryCode: "CM",
                        controller: _phoneController,
                        onChange: (dialCode, number) {
                          setState(() {
                            _phoneController.text = _formatWithSpaces(number);
                          });
                        },
                      ),
                      SizedBox(height: 1.6.h),
                      Text(
                        "Numéro WhatsApp",
                        style: TextStyle(fontSize: Adaptive.sp(12)),
                      ),
                      CustomPhoneField(
                        onTap: () {},
                        focus: true,
                        hint: "xxx....",
                        initialCountryCode: "CM",
                        controller: _whatsappController,
                        onChange: (dialCode, number) {
                          setState(() {
                            _whatsappController.text = _formatWithSpaces(
                              number,
                            );
                          });
                        },
                      ),
                      SizedBox(height: 1.6.h),
                      Text(
                        "Poste occupé",
                        style: TextStyle(fontSize: Adaptive.sp(12)),
                      ),
                      InputField(
                        controller: _jobTitleController,
                        hint: "Poste",
                        onTap: () {},
                        focus: true,
                        backColor: whiteColor,
                        textColor: blackColor,
                        prefixIcon: Icons.work_rounded,
                      ),
                      SizedBox(height: 2.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final updatedCollaborator = {
                              'name': _nameController.text,
                              'phone': _phoneController.text,
                              'whatsapp': _whatsappController.text,
                              'jobTitle': _jobTitleController.text,
                            };

                            final contactCubit = BlocProvider.of<ContactCubit>(
                              context,
                            );

                            await contactCubit.updateCollaborator(
                              widget.collaborator,
                              updatedCollaborator,
                            );

                            if (mounted) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Collaborateur mis à jour avec succès !",
                                  ),
                                  backgroundColor: greenColor,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: firstColor,
                            foregroundColor: whiteColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.w,
                              vertical: 1.5.h,
                            ),
                          ),
                          child: Text(
                            "Enregistrer",
                            style: TextStyle(
                              fontSize: Adaptive.sp(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Supprimer le collaborateur",
          ),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer ce collaborateur ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final contactCubit = BlocProvider.of<ContactCubit>(
                  context,
                );
                await contactCubit.deleteCollaborator(
                  widget.collaborator,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Collaborateur supprimé avec succès !",
                      ),
                      backgroundColor: redColor,
                    ),
                  );
                }
              },
              child: const Text(
                "Supprimer",
                style: TextStyle(color: redColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
