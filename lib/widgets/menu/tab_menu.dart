import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/api/google/google_signin.dart';
import 'package:jaguar_x_print/bloc/auth/auth_cubit.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/views/clients/fiche_client.dart';
import 'package:jaguar_x_print/views/code/code_machine.dart';
import 'package:jaguar_x_print/views/entretien/entretien.dart';
import 'package:jaguar_x_print/views/paiements/liste_paiement.dart';
import 'package:jaguar_x_print/constant/logout_confirmation.dart';
import 'package:jaguar_x_print/views/auth/login_screen.dart';
import 'package:jaguar_x_print/views/settings/settings_page.dart';
import 'package:jaguar_x_print/views/user/profile_page.dart';
import 'package:jaguar_x_print/models/user_model.dart';
import 'package:jaguar_x_print/widgets/menu/quad_image_row.dart';
import 'package:jaguar_x_print/views/settings/change_password_page.dart';

class TabBarMenu extends StatefulWidget {
  const TabBarMenu({super.key});

  @override
  State<TabBarMenu> createState() => _TabBarMenuState();
}

class _TabBarMenuState extends State<TabBarMenu>
    with SingleTickerProviderStateMixin {
  int _currentPageIndex = 0;
  final List<Widget> _pages = const [
    FicheClientPage(),
    CodeMachinePage(),
    EntretienPage(),
    ListePayementsPage(),
  ];
  UserModel? _currentUser;
  final List<Color> _pageColors = [color2, color1, color3, color4];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      setState(() => _currentUser = authState.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          setState(() => _currentUser = state.user);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _pages[_currentPageIndex],
        drawer: _buildDrawer(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(5.h),
        child: QuadImageRow(
          imagePaths: const [
            'assets/menu/client2.jpg',
            'assets/menu/cm2.jpg',
            'assets/menu/entretien2.jpg',
            'assets/menu/paiement2.jpg',
          ],
          titles: const ["Clients", "Machine", "Entretien", "Paiement"],
          titleColors: const [blackColor, whiteColor, whiteColor, blackColor],
          onTapCallbacks: [
                () => setState(() => _currentPageIndex = 0),
                () => setState(() => _currentPageIndex = 1),
                () => setState(() => _currentPageIndex = 2),
                () => setState(() => _currentPageIndex = 3),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.all(8.dp),
          child: Builder(
            builder: (BuildContext innerContext) {
              // Solution : Vérification robuste de l'URL
              ImageProvider? backgroundImage;

              if (_currentUser?.profilePhotoUrl != null &&
                  _currentUser!.profilePhotoUrl!.isNotEmpty &&
                  _currentUser!.profilePhotoUrl!.startsWith('http')) {
                backgroundImage = NetworkImage(_currentUser!.profilePhotoUrl!);
              } else {
                backgroundImage = const AssetImage('assets/logo/user.png');
              }

              return InkWell(
                onTap: () => Scaffold.of(innerContext).openDrawer(),
                child: CircleAvatar(
                  backgroundImage: backgroundImage,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: _pageColors[_currentPageIndex],
                ),
                accountName: Text(
                  _currentUser?.username ?? " ",
                  style: TextStyle(
                    fontSize: 18.dp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  _currentUser?.email ?? 'Aucun email',
                  style: TextStyle(fontSize: 14.dp),
                ),
                currentAccountPicture: Builder(
                  builder: (BuildContext context) {
                    // Vérification robuste de l'URL
                    ImageProvider<Object> backgroundImage;

                    if (_currentUser?.profilePhotoUrl != null &&
                        _currentUser!.profilePhotoUrl!.isNotEmpty &&
                        _currentUser!.profilePhotoUrl!.startsWith('http')) {
                      backgroundImage = NetworkImage(
                        _currentUser!.profilePhotoUrl!,
                      );
                    } else {
                      backgroundImage = const AssetImage(
                        'assets/logo/user.png',
                      );
                    }

                    return CircleAvatar(
                      backgroundImage: backgroundImage,
                    );
                  },
                ),
              );
            },
          ),
          _buildDrawerSection(
            title: 'CLOUD',
            children: [
              _buildDrawerTile(
                  icon: Icons.cloud_sync_rounded,
                  label: 'Gestion Cloud',
                  color: blueColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  }),
            ],
          ),
          _buildDrawerSection(
            title: 'APPLICATION',
            children: [
              // Changed from 'Préférences' to 'Paramètres' and navigation
              _buildDrawerTile(
                icon: Icons.settings_rounded,
                label: 'Paramètres',
                color: greenColor,
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              _buildDrawerTile(
                icon: Icons.help_outline_rounded,
                label: 'Aide & Support',
                color: yellowColor,
                onTap: () {/* ... */},
              ),
              _buildDrawerTile(
                icon: Icons.info_outline_rounded,
                label: 'À propos',
                color: Colors.grey[700]!,
                onTap: () {/* ... */},
              ),
            ],
          ),
          _buildLogoutSection(),
          Padding(
            padding: EdgeInsets.all(15.dp),
            child: Text(
              "Version 11.4.0",
              style: TextStyle(color: Colors.grey, fontSize: 12.dp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.dp,
            vertical: 10.dp,
          ),
          child: Text(
            title,
            style: TextStyle(color: greyColor, fontSize: 12.dp),
          ),
        ),
        ...children,
        const Divider(height: 20),
      ],
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(fontSize: 16.dp)),
      onTap: onTap,
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: EdgeInsets.all(15.dp),
      decoration: BoxDecoration(
        color: redColor.withOpacity(1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.logout_rounded,
          color: whiteColor,
        ),
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => _confirmLogout(context),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutConfirmation(
        onConfirm: () {
          GoogleSignInApi.signOut();
          context.read<AuthCubit>().logout();
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}