import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_x_print/api/database.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_bloc.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_event.dart';
import 'package:jaguar_x_print/bloc/paiement/paiement_state.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';
import 'package:jaguar_x_print/models/courrier_model.dart';
import 'package:jaguar_x_print/models/entretien_model.dart';
import 'package:jaguar_x_print/models/paiement_model.dart';
import 'package:jaguar_x_print/views/paiements/courriers/courrier_bottom_sheet.dart';
import 'package:jaguar_x_print/widgets/appbar_widget.dart';
import 'package:jaguar_x_print/widgets/clients/detail_row_widget.dart';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';
import 'package:jaguar_x_print/widgets/paiements/contact_card_paiement.dart';
import 'package:jaguar_x_print/widgets/paiements/paiement_bottom_sheet.dart';
import 'package:jaguar_x_print/widgets/paiements/paiement_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as path;

class PaiementDetailsPage extends StatefulWidget {
  final Contact contact;

  const PaiementDetailsPage({super.key, required this.contact});

  @override
  State<PaiementDetailsPage> createState() => _PaiementDetailsPageState();
}

class _PaiementDetailsPageState extends State<PaiementDetailsPage>
    with SingleTickerProviderStateMixin {
  // Section Paiements
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late final PaiementBloc _paiementBloc;
  List<Entretien> _entretiens = [];
  bool _isContractExpired = false;

  // Section Courriers
  List<Courrier> _courriers = [];
  List<Courrier> _filteredCourriers = [];
  bool _isLoadingCourriers = true;
  String _errorMessageCourriers = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  // Contrôleurs communs
  late TabController _tabController;
  // Déclarez cette variable dans votre classe
  final Set<String> _downloadingFiles = {};

  // Méthode utilitaire pour vérifier l'état
  bool _isDownloading(String url) => _downloadingFiles.contains(url);

  @override
  void initState() {
    super.initState();
    _paiementBloc = PaiementBloc(dbHelper: _dbHelper)
      ..add(
        LoadPaiements(contactId: widget.contact.id!),
      );
    _tabController = TabController(length: 2, vsync: this);
    _checkContractStatus();
    _loadEntretienData();
    _loadCourriers();
  }

  // Chargement des courriers
  Future<void> _loadCourriers() async {
    try {
      final courriers = await _dbHelper.getCourriersByContact(
        widget.contact.id!,
      );
      setState(() {
        _courriers = courriers;
        _filteredCourriers = courriers;
        _isLoadingCourriers = false;
      });
    } catch (e) {
      setState(() {
        _errorMessageCourriers = 'Erreur de chargement: ${e.toString()}';
        _isLoadingCourriers = false;
      });
    }
  }

  // Filtrage des courriers
  void _filterCourriers(String query) {
    setState(() {
      _filteredCourriers = _courriers.where((courrier) {
        final date = courrier.dateFormatted?.toLowerCase() ?? '';
        return date.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Méthode de confirmation de suppression
  void _confirmDeleteCourrier(Courrier courrier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer ce courrier ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCourrier(courrier);
            },
            child: const Text("Supprimer", style: TextStyle(color: redColor)),
          ),
        ],
      ),
    );
  }

  // Méthode de suppression effective
  Future<void> _deleteCourrier(Courrier courrier) async {
    try {
      await _dbHelper.deleteCourrier(courrier.id!);
      _refreshCourriers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Courrier supprimé",
            style: TextStyle(
              color: whiteColor,
            ),
          ),
          backgroundColor: greenColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
  }

  // Méthode d'édition
  void _editCourrier(BuildContext context, Courrier courrier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => CourrierBottomSheet(
        contactId: widget.contact.id!,
        existingCourrier: courrier,
        onCourrierAdded: _refreshCourriers,
      ),
    );
  }

  Widget _buildSlidableCourrierCard(BuildContext context, Courrier courrier) {
    return Slidable(
      key: Key(courrier.id.toString()),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _editCourrier(context, courrier),
            backgroundColor: blueColor,
            icon: Icons.edit_document,
            foregroundColor: whiteColor,
            label: 'Modifier',
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDeleteCourrier(courrier),
            backgroundColor: redColor,
            icon: Icons.delete_forever_rounded,
            foregroundColor: whiteColor,
            label: 'Supprimer',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          leading: Icon(
            Icons.description,
            color: color4,
            size: Adaptive.sp(28),
          ),
          title: Text(
            'Courrier du ${courrier.dateFormatted}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Adaptive.sp(15),
            ),
          ),
          subtitle: Text(
            path.basename(courrier.documentPath!),
            style: TextStyle(fontSize: Adaptive.sp(13)),
          ),
          trailing: IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.visibility),
                if (_isDownloading(courrier.serverDocumentUrl!))
                  Positioned(
                    right: 0,
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _openDocument(context, courrier),
          ),
        ),
      ),
    );
  }

  // Construction de l'interface des courriers
  Widget _buildCourriersList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                child: _showSearch
                    ? InputField(
                        onTap: () {
                          _searchController.clear();
                          _filterCourriers('');
                        },
                        focus: true,
                        backColor: whiteColor,
                        textColor: blackColor,
                        hint: "Rechercher par date",
                        controller: _searchController,
                        onChange: _filterCourriers,
                        prefixIcon: Icons.clear_rounded,
                      )
                    : const Text(
                        'Liste des courriers envoyés',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() => _showSearch = !_showSearch);
                  if (!_showSearch) {
                    _searchController.clear();
                    _filterCourriers('');
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingCourriers
              ? const Center(child: CircularProgressIndicator())
              : _errorMessageCourriers.isNotEmpty
                  ? Center(
                      child: Text(
                        _errorMessageCourriers,
                        style: const TextStyle(color: redColor),
                      ),
                    )
                  : _filteredCourriers.isEmpty
                      ? const Center(child: Text('Aucun courrier trouvé'))
                      : ListView.builder(
                          itemCount: _filteredCourriers.length,
                          itemBuilder: (context, index) {
                            final courrier = _filteredCourriers[index];
                            return _buildSlidableCourrierCard(
                              context,
                              courrier,
                            );
                          },
                        ),
        ),
      ],
    );
  }

  void _checkContractStatus() {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('dd/MM/yyyy');
      final startDate = formatter.parse(widget.contact.dateDebut);
      final endDate = formatter.parse(widget.contact.dateFin);

      setState(() {
        _isContractExpired = now.isBefore(startDate) || now.isAfter(endDate);
      });
    } catch (e) {
      if (kDebugMode) {
        print("Erreur de format de date : $e");
      }
    }
  }

  Future<void> _loadEntretienData() async {
    try {
      final entretien = await _dbHelper.getEntretiensByContact(
        widget.contact.id!,
      );
      setState(() => _entretiens = entretien);
    } catch (e) {
      _showErrorSnackBar(
        'Erreur de chargement des entretiens: ${e.toString()}',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: redColor,
      ),
    );
  }

  void _showPaiementBottomSheet([Paiement? existingPaiement]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: _paiementBloc,
        child: PaiementBottomSheet(
          contactId: widget.contact.id!,
          existingPaiement: existingPaiement,
        ),
      ),
    ).then((_) {
      _paiementBloc.add(
        LoadPaiements(
          contactId: widget.contact.id!,
        ),
      );
    });
  }

  void _refreshCourriers() {
    // Force le rechargement des courriers
    setState(() {
      _isLoadingCourriers = true;
      _errorMessageCourriers = '';
    });
    _loadCourriers();

    // Rafraîchit aussi les paiements
    _paiementBloc.add(LoadPaiements(contactId: widget.contact.id!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paiementBloc,
      child: BlocConsumer<PaiementBloc, PaiementState>(
        listener: (context, state) {
          if (state is PaiementError) {
            _showErrorSnackBar(state.message);
          } else if (state is PaiementSuccess && state.message.isNotEmpty) {
            _refreshCourriers();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: greenColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: _buildBody(state),
            floatingActionButton: _buildFloatingButton(),
          );
        },
      ),
    );
  }

  Widget _buildBody(PaiementState state) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: color4,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Column(
        children: [
          const AppBarWidget(
            imagePath: "assets/menu/paiement1.jpg",
            textColor: whiteColor,
            title: "Paiements",
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Adaptive.w(4),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaiementContactCard(contact: widget.contact),
                    SizedBox(height: 1.h),
                    _buildContractInfo(),
                    Container(
                      margin: EdgeInsets.only(top: 0.5.h),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: color4,
                        unselectedLabelColor: greyColor,
                        indicatorColor: color4,
                        tabs: const [
                          Tab(text: 'PAIEMENTS'),
                          Tab(text: 'COURRIERS')
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      height: 60.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPaiementsList(state),
                          _buildCourriersList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractInfo() {
    return Column(
      children: [
        DetailRow(
          title: "Date du contrat",
          value: "${widget.contact.dateDebut} - ${widget.contact.dateFin}",
        ),
        if (_isContractExpired) _buildExpiredWarning(),
        DetailRow(
          title: "Montant du contrat",
          value: "${widget.contact.montant} Fcfa",
        ),
        DetailRow(
          title: "État Machine",
          value: _entretiens.isNotEmpty && _entretiens.last.etatMachine != null
              ? _entretiens.last.etatMachine!
              : "Non renseigné",
        ),
      ],
    );
  }

  Widget _buildExpiredWarning() {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: redColor,
            size: Adaptive.sp(12),
          ),
          SizedBox(width: 1.w),
          Text(
            "Contrat expiré",
            style: TextStyle(
              color: redColor,
              fontSize: Adaptive.sp(12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaiementsList(PaiementState state) {
    if (state is PaiementLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: const CircularProgressIndicator(
            color: color4,
          ),
        ),
      );
    }

    if (state is PaiementSuccess) {
      if (state.paiements.isEmpty) {
        return Center(
          child: Text(
            "Aucun paiement enregistré",
            style: TextStyle(
              fontSize: Adaptive.sp(16),
            ),
          ),
        );
      }

      return Column(
        children: state.paiements
            .map(
              (p) => PaiementCard(
                paiement: p,
                key: ValueKey(p.id),
                onModify: () => _showPaiementBottomSheet(p),
                onDelete: () => _confirmDelete(p),
              ),
            )
            .toList(),
      );
    }

    // État initial - Chargement automatique
    if (state is PaiementInitial) {
      context.read<PaiementBloc>().add(
        LoadPaiements(contactId: widget.contact.id!),
      );
      return const Center(
        child: CircularProgressIndicator(
          color: color4,
        ),
      );
    }

    return Center(
      child: Text(
        "Erreur de chargement des données",
        style: TextStyle(
          color: redColor,
          fontSize: Adaptive.sp(16),
        ),
      ),
    );
  }

  // Mettre à jour le FloatingActionButton
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      backgroundColor: blueColor,
      foregroundColor: whiteColor,
      onPressed: () {
        if (_tabController.index == 0) {
          _showPaiementBottomSheet();
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => CourrierBottomSheet(
              contactId: widget.contact.id!,
              onCourrierAdded: () {
                // 🔥 Ajout du rechargement après l'ajout
                _refreshCourriers();
                _paiementBloc.add(
                  LoadPaiements(contactId: widget.contact.id!),
                );
              },
            ),
          ).then((_) => _refreshCourriers());
        }
      },
      child: const Icon(Icons.add),
    );
  }

  void _confirmDelete(Paiement paiement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer ce paiement ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              BlocProvider.of<PaiementBloc>(context).add(
                DeletePaiement(
                  paiementId: paiement.id!,
                  contactId: widget.contact.id!,
                ),
              );
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: redColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(BuildContext context, Courrier courrier) async {
    final String? documentUrl = courrier.serverDocumentUrl;
    final String? localPath = courrier.documentPath;
    File? file;
    bool isDownloading = false;

    try {
      // Cas 1: Document disponible sur le serveur
      if (documentUrl != null && documentUrl.startsWith('http')) {
        setState(() => _downloadingFiles.add(documentUrl));
        isDownloading = true;

        // Téléchargement depuis le serveur
        final response = await http.get(Uri.parse(documentUrl));
        if (response.statusCode != 200) throw Exception('Serveur indisponible');

        final tempDir = await getTemporaryDirectory();
        file = File('${tempDir.path}/${path.basename(documentUrl)}');
        await file.writeAsBytes(response.bodyBytes);
      }
      // Cas 2: Document local uniquement
      else if (localPath != null) {
        file = File(localPath);
        if (!await file.exists()) throw Exception('Fichier local introuvable');
      }
      // Cas 3: Aucune source valide
      else {
        throw Exception('Aucune source de document disponible');
      }

      // Vérification finale du fichier
      final fileExists = await file!.exists();
      if (!fileExists) throw Exception('Le fichier n\'a pas pu être chargé');

      // Ouverture selon le type de fichier
      if (file.path.toLowerCase().endsWith('.pdf')) {
        _openPdf(context, file);
      } else {
        _openImage(context, file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: redColor,
        ),
      );
    } finally {
      if (isDownloading && documentUrl != null) {
        setState(() => _downloadingFiles.remove(documentUrl));
      }
    }
  }


  void _openPdf(BuildContext context, File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Visualisateur PDF')),
          body: PdfViewPinch(
            controller: PdfControllerPinch(
              document: PdfDocument.openFile(file.path),
            ),
          ),
        ),
      ),
    );
  }

  void _openImage(BuildContext context, File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Visualisateur Image')),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              child: Image.file(file),
            ),
          ),
        ),
      ),
    );
  }
}
