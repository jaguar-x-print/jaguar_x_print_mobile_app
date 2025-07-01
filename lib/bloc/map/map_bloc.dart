import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaguar_x_print/bloc/map/map_event.dart';
import 'package:jaguar_x_print/bloc/map/map_state.dart';


class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<FetchCurrentLocation>(_onFetchCurrentLocation);
  }

  Future<void> _onFetchCurrentLocation(
      FetchCurrentLocation event,
      Emitter<MapState> emit,
      ) async {
    emit(MapLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(MapError('Location services are disabled.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(MapError('Location permissions are denied.'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(MapError('Location permissions are permanently denied.'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      emit(MapLoaded(LatLng(position.latitude, position.longitude)));
    } catch (e) {
      emit(MapError('Failed to fetch location: $e'));
    }
  }
}