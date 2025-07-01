import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/bloc/auth/auth_cubit.dart';
import 'package:jaguar_x_print/services/notification_service.dart';
import 'package:jaguar_x_print/views/auth/login_screen.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/menu/tab_menu.dart';

class PagePrincipale extends StatefulWidget {
  const PagePrincipale({super.key});

  @override
  State<PagePrincipale> createState() => _PagePrincipaleState();
}

class _PagePrincipaleState extends State<PagePrincipale> {
  bool _hasCheckedAuth = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCheckedAuth) {
        _hasCheckedAuth = true;
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthInitial || authState is! AuthSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: color1,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w),
            child: Column(
              children: [
                SizedBox(height: 1.2.h),
                SizedBox(height: Adaptive.h(1)),
                const AppBarWidget(
                  imagePath: "assets/menu/cm1.jpg",
                  textColor: whiteColor,
                  title: "Ecran Principal",
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMenuButton(context, "Fiche Client", color2),
                          SizedBox(height: 1.5.h),
                          _buildMenuButton(context, "Code Machine", color1),
                          SizedBox(height: 1.5.h),
                          _buildMenuButton(context, "Entretien", color3),
                          SizedBox(height: 1.5.h),
                          _buildMenuButton(context, "Liste des Payements", color4),
                          SizedBox(height: 1.5.h),


                          SizedBox(height: 5.h),
                          Image.asset(
                            'assets/logo/jaguar.png',
                            width: 45.w,
                            height: 45.w,
                          ),
                          SizedBox(height: 2.h),
                          _buildContactRow("00237 695 613 299"),
                          SizedBox(height: 0.2.h),
                          _buildContactRow("00237 678 582 664"),
                          SizedBox(height: 5.h),
                          Text(
                            "Cette application est la propriété exclusive de Jaguar x-Print",
                            style: TextStyle(fontSize: 14.dp),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.5.h),
                          Text(
                            "© Reproduction interdite même partielle",
                            style: TextStyle(fontSize: 14.dp),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, Color color) {
    final double luminance = color.computeLuminance();
    final Color textColor = luminance < 0.5 ? whiteColor : blackColor;

    final Map<String, Widget> pages = {
      "Fiche Client": const TabBarMenu(),
      "Code Machine": const TabBarMenu(),
      "Entretien": const TabBarMenu(),
      "Liste des Payements": const TabBarMenu(),
    };

    return GestureDetector(
      onTap: () {
        if (pages.containsKey(text)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pages[text]!),
          );
        }
      },
      child: Container(
        width: 90.w,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.dp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(String phoneNumber) {
    return SizedBox(
      width: 90.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/logo/whatsapp-icon.svg',
            width: 5.w,
          ),
          SizedBox(width: 1.w),
          Text(
            phoneNumber,
            style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
