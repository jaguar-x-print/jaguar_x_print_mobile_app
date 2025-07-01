import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/pages/page_5_6.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/card/client_name_card.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key, required this.contact});
  final Contact contact;

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  late Entretien _entretien;
  bool _isLoading = true;
  bool _hasChanges = false;
  final TextEditingController _problemeDecritController =
  TextEditingController();
  final TextEditingController _problemeEstimeController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntretien();
  }

  Future<void> _loadEntretien() async {
    final dbHelper = DatabaseHelper();
    List<Entretien> entretiens = await dbHelper.getEntretiensByContact(
      widget.contact.id!,
    );

    if (entretiens.isNotEmpty) {
      _entretien = entretiens.last;
      _problemeDecritController.text = _entretien.problemeDecrit ?? '';
      _problemeEstimeController.text = _entretien.problemeEstime ?? '';
    } else {
      _entretien = Entretien(
        contactId: widget.contact.id!,
        date: DateTime.now().toString(),
      );
      await dbHelper.insertEntretien(_entretien);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveEntretien() async {
    final dbHelper = DatabaseHelper();
    _entretien = _entretien.copyWith(
      problemeDecrit: _problemeDecritController.text,
      problemeEstime: _problemeEstimeController.text,
    );
    await dbHelper.updateEntretien(_entretien);
    setState(() => _hasChanges = false);
  }

  bool _validateFields() {
    return _problemeDecritController.text.isNotEmpty &&
        _problemeEstimeController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const CircularProgressIndicator();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Column(
          children: [
            const AppBarWidget(
              imagePath: "assets/menu/entretien1.jpg",
              textColor: whiteColor,
              title: "Entretien",
            ),
            SizedBox(height: 0.5.h),
            ClientNameCard(
              contact: widget.contact,
              page: "4/6",
            ),
            SizedBox(height: Adaptive.h(2)),
            Text(
              "Constat d'intervention",
              style: TextStyle(
                fontSize: Adaptive.sp(17),
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Adaptive.w(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Problème décrit par le client",
                      style: TextStyle(
                        fontSize: Adaptive.sp(15),
                      ),
                    ),
                    SizedBox(height: Adaptive.h(0.5)),
                    InputField(
                      controller: _problemeDecritController,
                      onChange: (value) {
                        _entretien = _entretien.copyWith(problemeDecrit: value);
                        setState(() => _hasChanges = true);
                      },
                      minLines: 5,
                      onTap: () {},
                      textColor: whiteColor,
                      focus: false,
                      hint: 'Saisissez ici le problème...',
                      hintColor: whiteColor,
                      keyboardType: TextInputType.multiline,
                      backColor: color3,
                    ),
                    SizedBox(height: Adaptive.h(3)),
                    Center(
                      child: Text(
                        "Constat avant intervention",
                        style: TextStyle(
                          fontSize: Adaptive.sp(17),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: Adaptive.h(1.5)),
                    Text(
                      "Problème estimé",
                      style: TextStyle(
                        fontSize: Adaptive.sp(15),
                      ),
                    ),
                    SizedBox(height: Adaptive.h(0.5)),
                    InputField(
                      controller: _problemeEstimeController,
                      onChange: (value) {
                        _entretien = _entretien.copyWith(problemeEstime: value);
                        setState(() => _hasChanges = true);
                      },
                      minLines: 5,
                      onTap: () {},
                      focus: false,
                      hint: 'Saisissez ici le problème estimé...',
                      hintColor: whiteColor,
                      textColor: whiteColor,
                      backColor: color3,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Adaptive.w(2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color3,
                      foregroundColor: whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: Adaptive.sp(13),
                        ),
                        SizedBox(width: Adaptive.w(1)),
                        Text(
                          'Précédent',
                          style: TextStyle(fontSize: Adaptive.sp(14)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_validateFields()) {
                        EasyLoading.show(status: 'Chargement...');
                        await _saveEntretien();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Page5(
                              contact: widget.contact,
                            ),
                          ),
                        );
                        EasyLoading.dismiss();
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Champs requis manquants"),
                            content: const Text(
                                "Veuillez remplir les deux champs de texte !"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color3,
                      foregroundColor: whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Suivant',
                          style: TextStyle(fontSize: Adaptive.sp(14)),
                        ),
                        SizedBox(width: Adaptive.w(1)),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: Adaptive.sp(13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Données non sauvegardées"),
        content: const Text(
            'Voulez-vous vraiment quitter sans sauvegarder ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }
}