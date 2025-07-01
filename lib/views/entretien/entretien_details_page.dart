// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/views/entretien/pages/start_entretien.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/entretien/contact_card_entretien.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:url_launcher/url_launcher.dart';

class EntretienDetailsPage extends StatefulWidget {
  const EntretienDetailsPage({
    super.key,
    required this.contact,
    this.entretien,
  });

  final Contact contact;
  final Entretien? entretien;

  @override
  State<EntretienDetailsPage> createState() => _EntretienDetailsPageState();
}

class _EntretienDetailsPageState extends State<EntretienDetailsPage> {
  late String _dropdownValue = "";
  late String _entretienDepannageValue = "";
  late String _etatMachineValue = "";
  List<String> _datesPremiereAnnee = [];
  String _lastNbTetesChangees = "0";
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  final bool _isLoadingRoute = false;
  double? _distanceInKm;
  double? _estimatedTime;

  @override
  void initState() {
    super.initState();
    _initContractStatus();
    _setDefaultValuesBasedOnContract();
    _loadExistingEntretienDates();
    _initMapMarker();
    _getCurrentLocation();
  }

  void _initMapMarker() {
    if (widget.contact.latitude != null && widget.contact.longitude != null) {
      final position = LatLng(
        widget.contact.latitude!,
        widget.contact.longitude!,
      );

      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('client_location'),
            position: position,
            infoWindow: InfoWindow(
              title: widget.contact.companyName ?? widget.contact.name,
              snippet: widget.contact.ville,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final location = loc.Location();
    try {
      final currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            infoWindow: const InfoWindow(title: 'Votre position'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      });

      // Centrer la carte sur la position actuelle
      if (_mapController != null && _currentLocation != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    } catch (e) {}
  }

  Future<void> _openInGoogleMaps() async {
    if (widget.contact.latitude == null || widget.contact.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Coordonnées de destination manquantes',
          ),
        ),
      );
      return;
    }

    final url = 'https://www.google.com/maps/dir/?api=1&destination=${widget.contact.latitude},${widget.contact.longitude}&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d\'ouvrir Google Maps',
          ),
        ),
      );
    }
  }

  Future<void> _loadExistingEntretienDates() async {
    try {
      final List<Entretien> entretiens = await _dbHelper.getEntretiensByContact(
        widget.contact.id!,
      );
      if(entretiens.isNotEmpty){
        // Tri des entretiens par date décroissante
        entretiens.sort((a, b) => a.date!.compareTo(b.date!));

        // Récupération du dernier entretien
        final dernierEntretien = entretiens.first;

        setState(() {
          _datesPremiereAnnee = entretiens.map((e) => e.date!).toList();
          _lastNbTetesChangees = dernierEntretien.changTete?.toString() ?? '0';
        });
      }
    } catch (e) {
      EasyLoading.showError('Erreur lors du chargement des entretiens: $e');
    }
  }

  void _setDefaultValuesBasedOnContract() {
    final status = _getContractStatus(
      widget.contact.dateDebut,
      widget.contact.dateFin,
    );

    // Définit la valeur du contrat et l'état initial
    if (status == "Contrat en cours") {
      _dropdownValue = "Oui";
      _entretienDepannageValue = "Entretien";
    } else {
      _dropdownValue = "Non";
      _entretienDepannageValue = "Dépannage";
    }
  }

  void _initContractStatus() {
    // Détermine automatiquement l'état du contrat au chargement
    final contractStatus = _getContractStatus(
      widget.contact.dateDebut,
      widget.contact.dateFin,
    );
  }

  String _getContractStatus(String startDate, String endDate) {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('dd/MM/yyyy');
      final parsedStartDate = formatter.parse(startDate);
      final parsedEndDate = formatter.parse(endDate);
      final today = DateTime(now.year, now.month, now.day);

      return (today.isAfter(
        parsedStartDate.subtract(
          const Duration(days: 1),
        ),
      ) &&
          today.isBefore(
            parsedEndDate.add(
              const Duration(days: 1),
            ),
          ))
          ? "Contrat en cours"
          : "Fin de contrat";
    } catch (e) {
      return "Format de date invalide";
    }
  }

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
          child: SingleChildScrollView(
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
                SizedBox(height: 0.5.h),
                EntretienContactCard(contact: widget.contact),
                SizedBox(height: Adaptive.h(1.5)),

                // Section de la carte avec itinéraire
                if (widget.contact.latitude != null && widget.contact.longitude != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Itinéraire vers l'entreprise",
                        style: TextStyle(
                          fontSize: Adaptive.sp(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: Adaptive.h(1)),
                      Container(
                        height: Adaptive.h(30),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    widget.contact.latitude!,
                                    widget.contact.longitude!,
                                  ),
                                  zoom: 15.0,
                                ),
                                markers: _markers,
                                polylines: _polylines,
                                onMapCreated: (controller) {
                                  setState(() {
                                    _mapController = controller;
                                  });
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                zoomControlsEnabled: true,
                                zoomGesturesEnabled: true,
                                scrollGesturesEnabled: true,
                              ),
                              if (_isLoadingRoute)
                                const Center(child: CircularProgressIndicator()),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Column(
                                  children: [
                                    SizedBox(height: Adaptive.h(0.5)),
                                    FloatingActionButton.small(
                                      onPressed: _openInGoogleMaps,
                                      backgroundColor: Colors.green,
                                      child: const Icon(
                                        Icons.open_in_new,
                                        color: whiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: Adaptive.h(1)),
                      if (_distanceInKm != null && _estimatedTime != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCard(
                              icon: Icons.directions_car,
                              title: 'Distance',
                              value: '${_distanceInKm!.toStringAsFixed(1)} km',
                            ),
                            _buildInfoCard(
                              icon: Icons.timer,
                              title: 'Temps estimé',
                              value: '${_estimatedTime!.toStringAsFixed(0)} min',
                            ),
                          ],
                        ),
                      SizedBox(height: Adaptive.h(1.5)),
                    ],
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(top: Adaptive.h(1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        SizedBox(width: Adaptive.w(2)),
                        Text(
                          "Localisation non définie",
                          style: TextStyle(
                            fontSize: Adaptive.sp(16),
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  _getContractStatus(
                    widget.contact.dateDebut,
                    widget.contact.dateFin,
                  ),
                  style: TextStyle(
                    fontSize: Adaptive.sp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Adaptive.h(1.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Client sous Contrat ?",
                      style: TextStyle(
                        fontSize: Adaptive.sp(17),
                      ),
                    ),
                    SizedBox(width: Adaptive.w(15)),
                    _buildDropdown(
                      value: _dropdownValue,
                      options: ["Oui", "Non"],
                      onChanged: (val) => setState(() {
                        _dropdownValue = val;
                        // Reset automatique du type d'intervention
                        _entretienDepannageValue = val == "Oui"
                            ? "Entretien"
                            : "Dépannage"; // Défaut sur Dépannage si Non
                      }),
                    ),
                  ],
                ),
                SizedBox(height: Adaptive.h(2)),
                Text(
                  "Entretien ou Dépannage",
                  style: TextStyle(
                    fontSize: Adaptive.sp(17),
                  ),
                ),
                SizedBox(height: Adaptive.h(0.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildEntretienDepannageDropdown(),
                  ],
                ),
                SizedBox(height: Adaptive.h(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "État Machine:",
                      style: TextStyle(
                        fontSize: Adaptive.sp(17),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: Adaptive.w(15)),
                    _buildDropdown(
                      value: _etatMachineValue,
                      options: ["", "Bloqué", "Non Bloqué"],
                      onChanged: (val) => setState(() {
                        _etatMachineValue = val;
                      }),
                    ),
                  ],
                ),
                SizedBox(height: Adaptive.h(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nbr têtes changées: $_lastNbTetesChangees",
                      style: TextStyle(fontSize: Adaptive.sp(16)),
                    ),
                    _buildDateSelector(),
                  ],
                ),
                SizedBox(height: Adaptive.h(2)),
                buildStartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(2)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: Adaptive.sp(20), color: color3),
            SizedBox(width: Adaptive.w(2)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Adaptive.sp(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Adaptive.sp(14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Modification de la méthode de construction du dropdown Entretien/Dépannage
  Widget _buildEntretienDepannageDropdown() {
    return _buildDropdown(
      value: _entretienDepannageValue,
      options: _dropdownValue == "Oui"
          ? ["Entretien", "Dépannage", "Entretien & Dépannage"]
          : ["Dépannage", "Entretien", "Entretien & Dépannage"],
      onChanged: (val) => setState(() {
        _entretienDepannageValue = val;
      }),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: blackColor, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: options.contains(value) ? value : "",
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            alignment: Alignment.centerRight,
            child: Text(
              option.isEmpty ? "" : option,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        style: TextStyle(
          fontSize: Adaptive.sp(17),
          color: blackColor,
        ),
        dropdownColor: whiteColor,
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          size: Adaptive.sp(15),
        ),
        iconSize: Adaptive.sp(24),
        underline: Container(),
        isDense: true,
      ),
    );
  }

  Widget _buildDateSelector() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "1ère année",
            style: TextStyle(
              fontSize: Adaptive.sp(16),
              decoration: TextDecoration.underline,
            ),
          ),
          if (_datesPremiereAnnee.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _datesPremiereAnnee.map((date) => Padding(
                padding: EdgeInsets.symmetric(vertical: 0.2.h),
                child: Text(
                  "Date: $date",
                  style: TextStyle(
                    fontSize: Adaptive.sp(13),
                  ),
                ),
              )).toList(),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.2.h),
              child: Text(
                "Aucun entretien",
                style: TextStyle(
                  fontSize: Adaptive.sp(14),
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildStartButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          EasyLoading.show(status: 'Chargement...');
          Future.delayed(const Duration(seconds: 2));
          EasyLoading.dismiss();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommencerEntretienPage(
                contact: widget.contact,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color3,
          foregroundColor: whiteColor,
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 1.2.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Commencer l'entretien",
          style: TextStyle(fontSize: Adaptive.sp(18)),
        ),
      ),
    );
  }
}