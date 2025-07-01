import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/pages/page_6_6.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/card/client_name_card.dart';
import 'package:jaguar_x_print/widgets/entretien/tools/dropdown.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key, required this.contact});
  final Contact contact;

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  late Entretien _entretien;
  bool _isLoading = true;
  bool _hasChanges = false;

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
    } else {
      _entretien = Entretien(
        contactId: widget.contact.id!,
        date: DateTime.now().toString(),
        // Valeurs par défaut
        changTete: '1',
        changCaps: 'Non',
        dampers: '1',
        wiper: '1',
        changPom: '1',
        graisRail: 'Non',
        changEncod: 'Non',
        changRast: 'Non',
        capsU: 'Non',
        dampersU: '1',
        wiperU: '1',
        pompeU: '1',
        roulRailU: 'Non',
        changEncodU: 'Non',
        changRastU: 'Non',
      );
      await dbHelper.updateEntretien(_entretien);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveEntretien() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.updateEntretien(_entretien);
    setState(() => _hasChanges = false);
  }

  bool _validateFields() {
    // Vérifie que tous les champs obligatoires sont remplis
    return _entretien.changTete != null &&
        _entretien.changCaps != null &&
        _entretien.dampers != null &&
        _entretien.wiper != null &&
        _entretien.changPom != null &&
        _entretien.graisRail != null &&
        _entretien.changEncod != null &&
        _entretien.changRast != null &&
        _entretien.capsU != null &&
        _entretien.dampersU != null &&
        _entretien.wiperU != null &&
        _entretien.pompeU != null &&
        _entretien.roulRailU != null &&
        _entretien.changEncodU != null &&
        _entretien.changRastU != null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const CircularProgressIndicator();

    return Scaffold(
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
            page: "5/6",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Adaptive.w(4)),
              child: Column(
                children: [
                  Text(
                    "Intervention et pièces remplacées:",
                    style: TextStyle(
                      fontSize: Adaptive.sp(17),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: Adaptive.h(0.5)),
                  EntretienDropdown(
                    label: "Changement tête ",
                    value: _entretien.changTete ?? '0',
                    items: const ['0', '1', '2', '3', '4', '5'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(changTete: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Changement Caps ",
                    value: _entretien.changCaps ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(changCaps: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Dampers ",
                    value: _entretien.dampers ?? '0',
                    items: const ['0', '1', '2', '3', '4', '5', '6', '7', '8'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(dampers: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Wiper ",
                    value: _entretien.wiper ?? '0',
                    items: const ['0', '1', '2'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(wiper: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Changement Pompe ",
                    value: _entretien.changPom ?? '0',
                    items: const ['0', '1', '2'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(changPom: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Graissage du Rail ",
                    value: _entretien.graisRail ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(graisRail: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Changement Encoder ",
                    value: _entretien.changEncod ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(changEncod: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Changement Raster ",
                    value: _entretien.changRast ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(changRast: v);
                      _hasChanges = true;
                    }),
                  ),
                  const Divider(
                    thickness: 1.2,
                    color: blackColor,
                  ),
                  Text(
                    "A Prévoir Rapidement : Urgent",
                    style: TextStyle(
                      fontSize: Adaptive.sp(17),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  EntretienDropdown(
                    label: "Caps ",
                    value: _entretien.capsU ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(capsU: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Dampers ",
                    value: _entretien.dampersU ?? '0',
                    items: const ['0', '1', '2', '3', '4', '5', '6', '7', '8'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(dampersU: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Wiper ",
                    value: _entretien.wiperU ?? '0',
                    items: const ['0', '1', '2'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(wiperU: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Pompe ",
                    value: _entretien.pompeU ?? '0',
                    items: const ['0', '1', '2'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(pompeU: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Roulement du Rail ",
                    value: _entretien.roulRailU ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(roulRailU: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Changement Encoder ",
                    value: _entretien.changEncodU ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(changEncodU: v);
                      _hasChanges = true;
                    }),
                  ),
                  EntretienDropdown(
                    label: "Changement Raster ",
                    value: _entretien.changRastU ?? 'Non',
                    items: const ['Oui', 'Non'],
                    onChanged: (v) => setState(() {
                      _entretien = _entretien.copyWith(changRastU: v);
                      _hasChanges = true;
                    }),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Adaptive.w(1)),
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
                                  builder: (context) => Page6(
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
                                      "Veuillez remplir toutes les sections !"),
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
          ),
        ],
      ),
    );
  }
}