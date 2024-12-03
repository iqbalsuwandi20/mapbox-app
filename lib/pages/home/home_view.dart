import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/map/map_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<MapBloc>().add(LoadMapEvent());

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapInitial) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blueGrey[900],
              ),
            );
          } else if (state is MapLoaded) {
            return FlutterMap(
              options: MapOptions(
                initialCenter: state.center,
                initialZoom: 17,
                onTap: (tapPosition, point) =>
                    context.read<MapBloc>().add(AddMarkerEvent(point)),
              ),
              children: [
                TileLayer(
                  urlTemplate: state.urlTemplate,
                  userAgentPackageName: 'com.example.mapbox_app',
                  additionalOptions: {"accessToken": state.accessToken},
                ),
                MarkerLayer(
                  markers: state.markers
                      .map(
                        (marker) => Marker(
                          point: marker,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red[900],
                            size: MediaQuery.of(context).size.width * 0.1,
                          ),
                        ),
                      )
                      .toList(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: state.polyline,
                      strokeWidth: 4.0,
                      color: Colors.blueGrey[900]!,
                    ),
                  ],
                ),
              ],
            );
          }
          return Center(
            child: Text(
              "Something went wrong",
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                color: Colors.red[900],
              ),
            ),
          );
        },
      ),
    );
  }
}
