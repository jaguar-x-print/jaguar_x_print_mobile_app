import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_bloc.dart';
import 'package:jaguar_x_print/bloc/entretien/entretien_event.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/widgets/entretien/details_row_entretien.dart';

class EntretienContactCard extends StatefulWidget {
  final Contact contact;

  const EntretienContactCard({super.key, required this.contact});

  @override
  State<EntretienContactCard> createState() => _EntretienContactCardState();
}

class _EntretienContactCardState extends State<EntretienContactCard> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isDatePassed = false;
  Entretien? _existingEntretien;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);

    final dbHelper = DatabaseHelper();
    final entretiens = await dbHelper.getEntretiensByContact(
      widget.contact.id!,
    );

    if (entretiens.isNotEmpty) {
      _existingEntretien = entretiens.last;
      if (_existingEntretien?.prochainEntretien != null) {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(
          _existingEntretien!.prochainEntretien!,
        );

        final now = DateTime.now();
        _isDatePassed = _selectedDate!.isBefore(
          DateTime(
            now.year,
            now.month,
            now.day,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      color: color3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCardContent(),
          if (_showWarningIcon) _buildWarningIcon(),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      width: Adaptive.w(95),
      padding: EdgeInsets.symmetric(horizontal: Adaptive.w(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Adaptive.h(2)),
              _buildCompanyInfo(),
              SizedBox(height: Adaptive.h(0.5)),
              _buildEmployeeInfo(),
              SizedBox(height: Adaptive.h(0.5)),
              _buildLocationInfo(),
              SizedBox(height: Adaptive.h(1)),
              _buildPhoneSection(),
              SizedBox(height: Adaptive.h(0.5)),
              _buildWhatsAppSection(),
              SizedBox(height: Adaptive.h(1)),
              _buildNextMaintenanceSection(),
              _buildContractDateSection(),
              SizedBox(height: Adaptive.h(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Text(
      "${widget.contact.companyName}",
      style: TextStyle(
        fontSize: Adaptive.sp(22),
        fontWeight: FontWeight.bold,
        color: whiteColor,
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Text(
      widget.contact.name,
      style: TextStyle(
        fontSize: Adaptive.sp(17),
        color: whiteColor,
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.contact.quartier!,
          style: TextStyle(
            color: whiteColor,
            fontSize: Adaptive.sp(18),
          ),
        ),
        SizedBox(height: Adaptive.h(0.5)),
        Text(
          widget.contact.ville!,
          style: TextStyle(
            color: whiteColor,
            fontSize: Adaptive.sp(18),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection() {
    return GestureDetector(
      onTap: () => _launchPhone(widget.contact.phone.first),
      child: Text(
        "Tél: ${widget.contact.phone.join(', ')}",
        style: TextStyle(
          fontSize: Adaptive.sp(18),
          color: whiteColor,
        ),
      ),
    );
  }

  Widget _buildWhatsAppSection() {
    return Center(
      child: GestureDetector(
        onTap: () => _launchWhatsApp(widget.contact.whatsapp),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Adaptive.w(2)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/logo/whatsapp-icon.svg',
                width: Adaptive.w(4.5),
              ),
              SizedBox(width: Adaptive.w(2)),
              Flexible(
                child: Text(
                  widget.contact.whatsapp,
                  style: TextStyle(
                    fontSize: Adaptive.sp(18),
                    color: whiteColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextMaintenanceSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Adaptive.w(1),
              vertical: Adaptive.h(1),
            ),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selectedDate == null
                  ? "Prochain entretien prévu le ..."
                  : "Prochain entretien prévu le ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Adaptive.sp(15),
                color: blackColor,
              ),
            ),
          ),
        ),
        if (_isDatePassed)
          Padding(
            padding: EdgeInsets.only(
              top: Adaptive.h(1),
            ),
            child: Text(
              "Date dépassée ! Veuillez planifier une nouvelle date",
              style: TextStyle(
                color: redColor,
                fontSize: Adaptive.sp(12),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContractDateSection() {
    return DetailsRowEntretien(
      title: "Date du contrat : ",
      value: "${widget.contact.dateDebut} - ${widget.contact.dateFin}",
    );
  }

  Widget _buildWarningIcon() {
    return Positioned(
      top: Adaptive.h(1),
      right: Adaptive.w(2),
      child: Icon(
        Icons.warning_amber_rounded,
        color: yellowColor,
        size: Adaptive.sp(48),
      ),
    );
  }

  bool get _showWarningIcon {
    return int.tryParse(widget.contact.montant!) != null &&
        int.parse(widget.contact.montant!) > 0;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      await _saveNextMaintenanceDate(picked);
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveNextMaintenanceDate(DateTime date) async {
    try {
      EasyLoading.show(status: 'Sauvegarde en cours...');

      final dbHelper = DatabaseHelper();
      final entretien = _existingEntretien?.copyWith(
            prochainEntretien: DateFormat('yyyy-MM-dd').format(date),
          ) ??
          Entretien(
            prochainEntretien: DateFormat('yyyy-MM-dd').format(date),
            date: DateTime.now().toString(),
          );

      if (_existingEntretien == null) {
        await dbHelper.insertEntretien(entretien);
      } else {
        await dbHelper.updateEntretien(entretien);
      }

      final now = DateTime.now();
      setState(() {
        _selectedDate = date;
        _isDatePassed = date.isBefore(
          DateTime(
            now.year,
            now.month,
            now.day,
          ),
        );
      });

      //context.read<EntretienBloc>().add(SaveEntretienEvent(entretien.toMap()));
      EasyLoading.dismiss();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: greenColor,
          content: Text('Date sélectionnée avec succès !'),
        ),
      );
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de sélection'),
          backgroundColor: redColor,
        ),
      );
    }
  }

  // Méthodes de lancement d'applications externes
  void _launchPhone(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    final Uri url = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
