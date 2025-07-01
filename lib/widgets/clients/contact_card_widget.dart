import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactCardWidget extends StatelessWidget {
  final Contact? contact;

  const ContactCardWidget({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: color5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Container(
              width: Adaptive.w(95),
              padding: EdgeInsets.symmetric(horizontal: Adaptive.w(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centrage principal
                children: [
                  SizedBox(height: Adaptive.h(2)),
                  // Nom de l'entreprise
                  Text(
                    contact!.companyName!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Adaptive.sp(25),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Adaptive.h(0.5)),
                  // Adresse
                  Column(
                    children: [
                      Text(
                        contact!.quartier!,
                        style: TextStyle(fontSize: Adaptive.sp(18)),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        contact!.ville!,
                        style: TextStyle(fontSize: Adaptive.sp(18)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: Adaptive.h(0.5)),
                  // Téléphone
                  GestureDetector(
                    onTap: () => _launchPhone(contact!.phone.first),
                    child: Text(
                      "Tél: ${contact!.phone.join(', ')}",
                      style: TextStyle(fontSize: Adaptive.sp(18)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // WhatsApp
                  Center(
                    child: GestureDetector(
                      onTap: () => _launchWhatsApp(context, contact!.whatsapp),
                      child: Padding(
                        padding: EdgeInsets.only(top: Adaptive.h(1)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/logo/whatsapp-icon.svg',
                              width: Adaptive.w(4.5),
                            ),
                            SizedBox(width: Adaptive.w(2)),
                            Flexible(
                              child: Text(
                                contact!.whatsapp,
                                style: TextStyle(fontSize: Adaptive.sp(18)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Lien groupe SAV
                  Center(
                    child: GestureDetector(
                      onTap: () => _launchWhatsAppGroup(
                        context,
                        contact!.groupeSAV,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: Adaptive.h(1)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link_rounded,
                              color: firstColor,
                              size: Adaptive.sp(18),
                            ),
                            SizedBox(width: Adaptive.w(1)),
                            Text(
                              "Rejoindre le groupe SAV",
                              style: TextStyle(
                                fontSize: Adaptive.sp(16),
                                color: firstColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Adaptive.h(2)),
                ],
              ),
            ),
            // Icône d'avertissement
            if (int.tryParse(contact!.montant!) != null && int.parse(contact!.montant!) > 0)
              Positioned(
                bottom: Adaptive.h(1),
                right: Adaptive.w(2),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: yellowColor,
                  size: Adaptive.sp(24),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Impossible d'ouvrir l'application d'appel.");
    }
  }

  void _launchWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ce contact ne possède pas de compte WhatsApp."),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    final Uri url = Uri.parse("https://wa.me/$phoneNumber");

    final AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: url.toString(),
      package: null,
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    try {
      await intent.launch();
    } catch (e) {
      debugPrint("Erreur : $e");
    }
  }

  void _launchWhatsAppGroup(BuildContext context, String? groupLink) async {
    if (groupLink == null || groupLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun groupe SAV associé à ce contact."),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    final Uri url = Uri.parse(groupLink);

    final AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: url.toString(),
      package: null,
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    try {
      await intent.launch();
    } catch (e) {
      debugPrint("Erreur : $e");
    }
  }

}
