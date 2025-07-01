import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/pages/page_4_6.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/card/client_name_card.dart';
import 'package:jaguar_x_print/widgets/entretien/tools/dropdown.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key, required this.contact});
  final Contact contact;

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
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
      _entretien = const Entretien(
        regulTension: "Non",
        capaRegulTension: "2000V",
        priseT: "Non",
        local: "Fermé",
        temp: "Elevée",
        encreJxP: "Non",
        netJxP: "Non",
        etatGenIm: "Bon",
      );
      await dbHelper.insertEntretien(_entretien);
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
    return _entretien.regulTension != null &&
        _entretien.priseT != null &&
        _entretien.local != null &&
        _entretien.temp != null &&
        _entretien.encreJxP != null &&
        _entretien.netJxP != null &&
        _entretien.etatGenIm != null &&
        // Si régulateur tension est "Oui", vérifier la capacité
        (_entretien.regulTension != 'Oui' ||
            (_entretien.capaRegulTension != null &&
                _entretien.capaRegulTension!.isNotEmpty));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const CircularProgressIndicator();

    return Padding(
      padding: const EdgeInsets.all(1.0),
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
              page: "3/6",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Adaptive.w(4)),
                child: Column(
                  children: [
                    EntretienDropdown(
                      label: "Régulateur tension :",
                      value: _entretien.regulTension ?? 'Non',
                      items: const ['Oui', 'Non'],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(regulTension: v);
                        if (v == 'Non') {
                          _entretien = _entretien.copyWith(
                            capaRegulTension: '',
                          );
                        } else {
                          _entretien = _entretien.copyWith(
                            capaRegulTension: '2000V',
                          );
                        }
                        _hasChanges = true;
                      }),
                    ),
                    EntretienDropdown(
                      label: "Capacité régulateur tension :",
                      value: _entretien.regulTension == 'Non'
                          ? ''
                          : _entretien.capaRegulTension ?? '2000V',
                      items: const ['2000V', '2500V', '3500V', '5000V'],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(capaRegulTension: v);
                        _hasChanges = true;
                      }),
                      enabled: _entretien.regulTension == 'Oui',
                    ),
                    EntretienDropdown(
                      label: "Prise terre :",
                      value: _entretien.priseT ?? 'Non',
                      items: const ['Oui', 'Non'],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(priseT: v);
                        _hasChanges = true;
                      }),
                    ),
                    EntretienDropdown(
                      label: "Local Fermé-Ouvert :",
                      value: _entretien.local ?? 'Fermé',
                      items: const ['Fermé', 'Ouvert'],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(local: v);
                        _hasChanges = true;
                      }),
                    ),
                    EntretienDropdown(
                      label: "Température :",
                      value: _entretien.temp ?? 'Elevée',
                      items: const ['Elevée', 'Normale', 'Basse'],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(temp: v);
                        _hasChanges = true;
                      }),
                    ),
                    EntretienDropdown(
                      label: "Utilisation d'encres Jaguar x-Print :",
                      value: _entretien.encreJxP ?? 'Non',
                      items: const ['Oui', 'Non'],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(encreJxP: v);
                        _hasChanges = true;
                      }),
                    ),
                    EntretienDropdown(
                      label: "Nettoyant Jaguar x-Print :",
                      value: _entretien.netJxP ?? 'Non',
                      items: const ['Oui', 'Non'],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(netJxP: v);
                        _hasChanges = true;
                      }),
                    ),
                    EntretienDropdown(
                      label: "État général de l'imprimante :",
                      value: _entretien.etatGenIm ?? 'Bon',
                      items: const [
                        'Bon',
                        'Moyen',
                        'Bcp de Poussières',
                        'Abandonnée'
                      ],
                      onChanged: (v) => setState(() {
                        _entretien = _entretien.copyWith(etatGenIm: v);
                        _hasChanges = true;
                      }),
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
                            builder: (context) => Page4(
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
                                "Veuillez sélectionner une valeur pour tous les champs obligatoires !"),
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
}