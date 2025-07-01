import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/views/notifications/notification_page.dart';
import 'package:jaguar_x_print/views/settings/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paramètres",
          style: TextStyle(
            color: whiteColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: blueColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: whiteColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(Adaptive.w(4)),
        children: [
          // Section du mot de passe paiement
          _buildPaymentPasswordSection(),

          SizedBox(height: Adaptive.h(3)),

          // Section des notifications
          _buildNotificationSection(),

          SizedBox(height: Adaptive.h(3)),

          // Section Politique de confidentialité
          _buildPrivacyPolicySection(),
        ],
      ),
    );
  }

  Widget _buildPaymentPasswordSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordPage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(Adaptive.w(4)),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(Adaptive.w(3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: Adaptive.sp(22),
                  color: Colors.blue,
                ),
                SizedBox(width: Adaptive.w(4)),
                Text(
                  "Modifier mot de passe paiement",
                  style: TextStyle(
                    fontSize: Adaptive.sp(15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: Adaptive.sp(16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScheduleNotificationsPage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(Adaptive.w(4)),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(Adaptive.w(3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  size: Adaptive.sp(22),
                  color: Colors.blue,
                ),
                SizedBox(width: Adaptive.w(4)),
                Text(
                  "Programmer les notifications",
                  style: TextStyle(
                    fontSize: Adaptive.sp(15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: Adaptive.sp(16),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPrivacyPolicySection() {
    return GestureDetector(
      onTap: () {
        // Ajouter ici la navigation vers la page de politique de confidentialité
        debugPrint("Ouvrir la politique de confidentialité");
        // Exemple: Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
      },
      child: Container(
        padding: EdgeInsets.all(Adaptive.w(4)),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(Adaptive.w(3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_rounded,
                  size: Adaptive.sp(22),
                  color: Colors.blue,
                ),
                SizedBox(width: Adaptive.w(4)),
                Text(
                  "Politique de confidentialité",
                  style: TextStyle(
                    fontSize: Adaptive.sp(15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: Adaptive.sp(16),
            ),
          ],
        ),
      ),
    );
  }
}