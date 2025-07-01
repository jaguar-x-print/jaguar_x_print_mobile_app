import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaguar_x_print/bloc/map/map_bloc.dart';
import 'package:jaguar_x_print/bloc/map/map_event.dart';
import 'package:jaguar_x_print/bloc/map/map_state.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key, required this.contactId, this.onMapCreated});

  final int contactId;
  final void Function(GoogleMapController)? onMapCreated;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc()..add(FetchCurrentLocation()),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Center(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: Adaptive.w(90),
                height: Adaptive.h(35.7),
                child: _buildMapContent(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapContent(BuildContext context, MapState state) {
    if (state is MapLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MapLoaded) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: state.currentLocation,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          if (onMapCreated != null) {
            onMapCreated!(controller);
          }
        },
      );
    } else if (state is MapError) {
      return Center(child: Text(state.message));
    } else {
      return const SizedBox.shrink();
    }
  }
}