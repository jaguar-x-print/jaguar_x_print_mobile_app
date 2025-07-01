import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_bloc.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_event.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/paiement_model.dart';
import 'package:jaguar_x_print/widgets/dropdown_button.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class PaiementBottomSheet extends StatefulWidget {
  final int contactId;
  final Paiement? existingPaiement;

  const PaiementBottomSheet({
    super.key,
    required this.contactId,
    this.existingPaiement,
  });

  @override
  State<PaiementBottomSheet> createState() => _PaiementBottomSheetState();
}

class _PaiementBottomSheetState extends State<PaiementBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMonth;
  DateTime? _selectedDate;
  String? _selectedPaymentMethod;
  late final TextEditingController _resteAPayerController;
  late final TextEditingController _penaliteController;
  late final TextEditingController _dateController;

  final List<String> _months = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  final List<String> _paymentMethods = [
    "OM (Orange Money)",
    "MOMO (MTN Mobile Money)",
    "CASH",
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingData();
  }

  void _initializeControllers() {
    _resteAPayerController = TextEditingController(text: '');
    _penaliteController = TextEditingController(text: '');
    _dateController = TextEditingController(text: '');
  }

  void _loadExistingData() {
    if (widget.existingPaiement != null) {
      final p = widget.existingPaiement!;
      _selectedMonth = p.mois;
      _selectedPaymentMethod = p.mode;
      _resteAPayerController.text = p.resteAPayer!;
      _penaliteController.text = p.penalite!;
      _dateController.text = p.date!;
      _selectedDate = DateFormat('dd/MM/yyyy').parse(p.date!);
    } else {
      _dateController.text = "Sélectionner une date";
      _selectedDate = DateTime.now();
    }
  }

  void _pickDate() async {
    DateTime? initial = _selectedDate ?? DateTime.now();
    DateTime? first;
    DateTime? last;

    if (_selectedMonth != null) {
      final monthIndex = _months.indexOf(_selectedMonth!);
      final year = _selectedDate?.year ?? DateTime.now().year;
      first = DateTime(year, monthIndex + 1, 1);
      last = DateTime(year, monthIndex + 2, 0);
      initial = first;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime(2000),
      lastDate: last ?? DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        if (_selectedMonth == null) {
          _selectedMonth = _months[picked.month - 1];
        }
      });
    }
  }

  void _savePaiement() async {
    if (_formKey.currentState!.validate()) {
      final paiement = Paiement(
        id: widget.existingPaiement?.id,
        contactId: widget.contactId,
        mois: _selectedMonth!,
        date: _dateController.text,
        mode: _selectedPaymentMethod!,
        resteAPayer: _resteAPayerController.text,
        penalite: _penaliteController.text,
      );

      final bloc = context.read<PaiementBloc>();

      if (widget.existingPaiement != null) {
        bloc.add(UpdatePaiement(
          paiement: paiement,
          contactId: widget.contactId,
        ));
      } else {
        bloc.add(AddPaiement(
          paiement: paiement,
          contactId: widget.contactId,
        ));
      }

      // Attendre la mise à jour avant de fermer
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.pop(context);
    }
  }

  String getRecapText() {
    return "Reste à payer pour ${_selectedMonth ?? 'le mois sélectionné'} : "
        "${_resteAPayerController.text.isNotEmpty ? _resteAPayerController.text : '0'} FCFA";
  }

  @override
  void dispose() {
    _resteAPayerController.dispose();
    _penaliteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Adaptive.w(4),
        right: Adaptive.w(4),
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildMonthField(),
              _buildDateField(),
              _buildPaymentMethodField(),
              _buildAmountFields(),
              _buildSaveButton(),
              SizedBox(height: Adaptive.h(1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(Adaptive.w(2)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Adaptive.w(7)),
                color: greenYellowColor,
              ),
              height: Adaptive.h(0.6),
              width: Adaptive.w(25),
            ),
          ),
        ),
        SizedBox(height: Adaptive.h(2)),
        Center(
          child: Text(
            widget.existingPaiement != null
                ? "Modifier le paiement"
                : "Ajouter un paiement",
            style: TextStyle(
              fontSize: Adaptive.sp(18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: Adaptive.h(2)),
      ],
    );
  }

  Widget _buildMonthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mois de paiement", style: TextStyle(fontSize: Adaptive.sp(16))),
        DropdownField<String>(
          focus: false,
          hint: "Sélectionner le mois",
          value: _selectedMonth,
          onChanged: (value) => setState(() => _selectedMonth = value),
          items: _months.map((month) {
            return DropdownMenuItem(value: month, child: Text(month));
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) return "Champ obligatoire";
            if (_selectedDate != null &&
                _months.indexOf(value) != _selectedDate!.month - 1) {
              return "Incohérence avec la date sélectionnée";
            }
            return null;
          },
          prefixIcon: Icons.calendar_month,
        ),
        SizedBox(height: Adaptive.h(1.5)),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date de paiement", style: TextStyle(fontSize: Adaptive.sp(16))),
        InputField(
          onTap: _pickDate,
          focus: true,
          textColor: blackColor,
          backColor: whiteColor,
          hint: "Sélectionner une date",
          controller: _dateController,
          validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
          readOnly: true,
          prefixIcon: Icons.calendar_today,
        ),
        SizedBox(height: Adaptive.h(1.5)),
      ],
    );
  }

  Widget _buildPaymentMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mode de paiement", style: TextStyle(fontSize: Adaptive.sp(16))),
        DropdownField<String>(
          focus: false,
          hint: "Sélectionner le mode",
          value: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value),
          items: _paymentMethods.map((method) {
            return DropdownMenuItem(value: method, child: Text(method));
          }).toList(),
          validator: (value) => value == null ? "Champ obligatoire" : null,
          prefixIcon: Icons.payment,
        ),
        SizedBox(height: Adaptive.h(1.5)),
      ],
    );
  }

  Widget _buildAmountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reste à payer", style: TextStyle(fontSize: Adaptive.sp(16))),
        InputField(
          onTap: () {},
          focus: true,
          textColor: blackColor,
          backColor: whiteColor,
          controller: _resteAPayerController,
          hint: "Montant",
          validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.payments_rounded,
        ),
        SizedBox(height: Adaptive.h(1.5)),
        Text("Pénalité", style: TextStyle(fontSize: Adaptive.sp(16))),
        InputField(
          onTap: () {},
          textColor: blackColor,
          backColor: whiteColor,
          focus: true,
          controller: _penaliteController,
          hint: "Montant",
          validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.warning_amber_rounded,
        ),
        SizedBox(height: Adaptive.h(2)),
        Center(child: Text(getRecapText(), style: _recapStyle())),
        SizedBox(height: Adaptive.h(2)),
      ],
    );
  }

  TextStyle _recapStyle() {
    return TextStyle(
      fontSize: Adaptive.sp(16),
      fontWeight: FontWeight.bold,
      color: blackColor,
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _savePaiement,
        style: ElevatedButton.styleFrom(
          backgroundColor: greenYellowColor,
          padding: EdgeInsets.symmetric(
            horizontal: Adaptive.w(22),
            vertical: Adaptive.h(1),
          ),
        ),
        child: Text(
          "Enregistrer",
          style: TextStyle(
            color: blackColor,
            fontSize: Adaptive.sp(16),
          ),
        ),
      ),
    );
  }
}