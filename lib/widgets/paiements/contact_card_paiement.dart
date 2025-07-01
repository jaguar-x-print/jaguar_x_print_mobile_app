import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/widgets/entretien/details_row_entretien.dart';

class PaiementContactCard extends StatefulWidget {
  final Contact contact;

  const PaiementContactCard({super.key, required this.contact});

  @override
  State<PaiementContactCard> createState() => _PaiementContactCardState();
}

class _PaiementContactCardState extends State<PaiementContactCard> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isDatePassed = false;

  @override
  void initState() {
    super.initState();
    //_loadExistingData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Card(
        color: color4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            _buildCardContent(),
            if (_showWarningIcon) _buildWarningIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      width: Adaptive.w(95),
      padding: EdgeInsets.symmetric(horizontal: Adaptive.w(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Adaptive.h(2)),
          _buildCompanyInfo(),
          SizedBox(height: Adaptive.h(0.5)),
          _buildEmployeeInfo(),
          SizedBox(height: Adaptive.h(0.5)),
          _buildLocationInfo(),
          SizedBox(height: Adaptive.h(1)),
          _buildPhoneSection(),
          _buildWhatsAppSection(),
          SizedBox(height: Adaptive.h(1)),
          _buildPaiementDateSection(),
          SizedBox(height: Adaptive.h(1)),
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
        color: blackColor,
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Text(
      widget.contact.name,
      style: TextStyle(
        fontSize: Adaptive.sp(17),
        color: blackColor,
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
            color: blackColor,
            fontSize: Adaptive.sp(18),
          ),
        ),
        SizedBox(height: Adaptive.h(0.5)),
        Text(
          widget.contact.ville!,
          style: TextStyle(
            color: blackColor,
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
          color: blackColor,
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
                    color: blackColor,
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

  Widget _buildPaiementDateSection() {
    return Center(
      child: Column(
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
                "Paiement avant le ${widget.contact.jourPaiement} du mois",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Adaptive.sp(15),
                  color: blackColor,
                  fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Positioned(
      top: Adaptive.h(1),
      right: Adaptive.w(2),
      child: Icon(
        Icons.warning_amber_rounded,
        color: redColor,
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
      // await _savePaiementDate(picked);
      setState(() => _selectedDate = picked);
    }
  }
/*
  Future<void> _savePaiementDate(DateTime date) async {
    try {
      EasyLoading.show(status: 'Sauvegarde en cours...');

      final dbHelper = DatabaseHelper();
      final paiement = _existingPaiement?.copyWith(
            prochainPaiement: DateFormat('yyyy-MM-dd').format(date),
          ) ??
          Entretien(
            contactId: widget.contact.id!,
            prochainEntretien: DateFormat('yyyy-MM-dd').format(date),
            date: DateTime.now().toString(),
          );

      if (_existingPaiement == null) {
        await dbHelper.insertEntretien(paiement);
      } else {
        await dbHelper.updateEntretien(paiement);
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

      context.read<EntretienBloc>().add(SaveEntretienEvent(paiement.toMap()));
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
  */

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
