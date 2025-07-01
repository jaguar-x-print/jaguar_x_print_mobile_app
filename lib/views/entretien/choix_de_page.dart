import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/views/entretien/entretien_details_page.dart';
import 'package:jaguar_x_print/views/entretien/liste_entretien.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';

class EntretienHomePage extends StatefulWidget {
  const EntretienHomePage({
    super.key,
    required this.contact,
  });

  final Contact contact;

  @override
  State<EntretienHomePage> createState() => _EntretienHomePageState();
}

class _EntretienHomePageState extends State<EntretienHomePage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: color3,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(Adaptive.w(3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: AppBarWidget(
                  imagePath: "assets/menu/entretien1.jpg",
                  textColor: whiteColor,
                  title: "Entretien",
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton Nouvel Entretien
                    _buildActionCard(
                      context,
                      icon: Icons.add_circle_outline,
                      title: "Nouvel Entretien",
                      subtitle: "Commencer un nouvel entretien technique",
                      color: green2Color,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EntretienDetailsPage(
                              contact: widget.contact,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 4.h),

                    // Bouton Liste des Entretiens
                    _buildActionCard(
                      context,
                      icon: Icons.format_list_bulleted,
                      title: "Historique des Entretiens",
                      subtitle: "Consulter l'historique des interventions",
                      color: color3,
                      // Dans votre liste de contacts
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListeEntretienPage(
                              contact: widget.contact,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Adaptive.w(5)),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: blackColor,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Adaptive.w(4)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Adaptive.w(10),
                color: color,
              ),
            ),
            SizedBox(width: Adaptive.w(5)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Adaptive.sp(16),
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Adaptive.sp(12),
                      color: greyColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: Adaptive.w(8),
              color: greyColor,
            ),
          ],
        ),
      ),
    );
  }
}
