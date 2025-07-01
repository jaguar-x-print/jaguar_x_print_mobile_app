import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final LatLng currentLocation;

  MapLoaded(this.currentLocation);
}

class MapError extends MapState {
  final String message;

  MapError(this.message);
}