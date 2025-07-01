import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/contact_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/clients/contact_card_widget.dart';
import 'package:jaguar_x_print/widgets/clients/detail_row_widget.dart';
import 'package:jaguar_x_print/widgets/date_blocage_widget.dart';
import 'package:jaguar_x_print/widgets/clients/blocage_field.dart';
import 'package:jaguar_x_print/widgets/clients/comment_field.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class CodeMachineDetailsPage extends StatefulWidget {
  final Contact contact;

  const CodeMachineDetailsPage({super.key, required this.contact});

  @override
  State<CodeMachineDetailsPage> createState() => _CodeMachineDetailsPageState();
}

class _CodeMachineDetailsPageState extends State<CodeMachineDetailsPage> {
  final TextEditingController commentController = TextEditingController();
  final TextEditingController blocageHeuresController = TextEditingController();
  String dateOfLock = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContactDetails();
  }

  Future<void> _loadContactDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final contact = await DatabaseHelper().getContactById(widget.contact.id!);
      if (contact != null) {
        setState(() {
          commentController.text = contact.commentaire ?? "";
          blocageHeuresController.text = contact.blocageHeures ?? "";
          dateOfLock = contact.dateOfLock ?? "";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact non trouvé.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await context.read<ContactCubit>().updateContactDetailsFromCodeMachine(
        commentController.text,
        blocageHeuresController.text,
        dateOfLock,
      );
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde réussie !')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sauvegarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmer la sortie"),
            content: Text(
              "Êtes-vous sûr de vouloir quitter ? Toutes les données non enregistrées seront perdues.",
              style: TextStyle(
                fontSize: Adaptive.sp(13),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "Annuler",
                  style: TextStyle(
                    color: redColor,
                    fontSize: Adaptive.sp(17),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  "Confirmer",
                  style: TextStyle(
                    color: green2Color,
                    fontSize: Adaptive.sp(17),
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldPop ?? false) {
          Navigator.of(context).pop();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: color1,
          statusBarIconBrightness: Brightness.light,
        ),
        child: BlocBuilder<ContactCubit, ContactState>(
          builder: (context, state) {
            final contact = state.selectedContact ?? widget.contact;

            return Scaffold(
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: EdgeInsets.all(Adaptive.w(3)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBarWidget(
                        imagePath: "assets/menu/cm1.jpg",
                        textColor: whiteColor,
                        title: 'Code Machine',
                      ),
                      ContactCardWidget(contact: widget.contact),
                      SizedBox(height: Adaptive.h(2)),
                      DetailRow(
                        title: "Date du contrat",
                        value: "${widget.contact.dateDebut} - ${widget.contact.dateFin}",
                      ),
                      CodesMachineDetailsWidget(
                        contact: widget.contact,
                        onCodeAdded: _loadContactDetails,
                        onCodeModified: _loadContactDetails,
                      ),
                      SizedBox(height: Adaptive.h(2)),
                      DateBlocageWidget(
                        title: "Date de blocage",
                        initialValue: dateOfLock,
                        onDateSelected: (selectedDate) {
                          setState(() {
                            dateOfLock = selectedDate!;
                          });
                        },
                      ),
                      SizedBox(height: Adaptive.h(1)),
                      BlocageField(
                        blocageHeuresController: blocageHeuresController,
                      ),
                      SizedBox(height: Adaptive.h(2)),
                      CommentsField(
                        commentController: commentController,
                      ),
                      SizedBox(height: Adaptive.h(2)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: redColor,
                              foregroundColor: whiteColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Retour",
                              style: TextStyle(fontSize: Adaptive.sp(16)),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green2Color,
                              foregroundColor: whiteColor,
                            ),
                            onPressed: _saveChanges,
                            child: Text(
                              "Enregistrer",
                              style: TextStyle(fontSize: Adaptive.sp(16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CodesMachineDetailsWidget extends StatelessWidget {
  final Contact contact;
  final VoidCallback onCodeAdded;
  final VoidCallback onCodeModified;

  const CodesMachineDetailsWidget({
    super.key,
    required this.contact,
    required this.onCodeAdded,
    required this.onCodeModified,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchCodesMachine(contact.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Erreur : ${snapshot.error}");
        } else {
          List<String> codesMachine = snapshot.data ?? [];
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
                    (code) => InkWell(
                  onLongPress: () => _showModifyCodeDialog(context, code),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: Adaptive.h(0.5)),
                    width: Adaptive.w(80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(Adaptive.w(2)),
                              child: Text(
                                code,
                                style: TextStyle(
                                  color: blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Adaptive.sp(16),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
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
        }
      },
    );
  }

  Future<List<String>> _fetchCodesMachine(int contactId) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (maps.isNotEmpty) {
      final contact = Contact.fromMap(maps.first);
      return contact.codesMachine;
    }

    return [];
  }

  void _showCodeMachineDialog(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Ajouter un Code Machine",
            style: TextStyle(fontSize: Adaptive.sp(18)),
          ),
          content: InputField(
            controller: codeController,
            onTap: () {},
            backColor: whiteColor,
            focus: true,
            hint: 'Saisissez le code machine',
            textColor: blackColor,
            prefixIcon: Icons.numbers_rounded,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Annuler",
                style: TextStyle(fontSize: Adaptive.sp(16)),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (codeController.text.isNotEmpty) {
                  await context
                      .read<ContactCubit>()
                      .addCodeMachineFromCodeMachine(
                      contact.id!, codeController.text);
                  Navigator.of(context).pop();
                  onCodeAdded();
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

  void _showModifyCodeDialog(BuildContext context, String oldCode) {
    TextEditingController codeController = TextEditingController(text: oldCode);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Modifier le Code Machine",
            style: TextStyle(fontSize: Adaptive.sp(18)),
          ),
          content: InputField(
            controller: codeController,
            onTap: () {},
            focus: true,
            backColor: whiteColor,
            textColor: blackColor,
            hint: 'Modifier le code machine',
            prefixIcon: Icons.numbers_rounded,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Annuler",
                style: TextStyle(fontSize: Adaptive.sp(16)),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (codeController.text.isNotEmpty) {
                  await context
                      .read<ContactCubit>()
                      .modifyCodeMachineFromCodeMachine(
                      contact.id!, oldCode, codeController.text);
                  Navigator.of(context).pop();
                  onCodeModified();
                }
              },
              child: Text(
                "Modifier",
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