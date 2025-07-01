import 'package:jaguar_x_print/models/courrier_model.dart';

abstract class CourrierState {}

class CourrierInitial extends CourrierState {}

class CourrierLoading extends CourrierState {}

class CourrierAdded extends CourrierState {}

class CourrierError extends CourrierState {
  final String message;

  CourrierError(this.message);
}

class CourriersLoaded extends CourrierState {
  final List<Courrier> courriers;

  CourriersLoaded(this.courriers);
}