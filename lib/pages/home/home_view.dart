import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

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
            return Stack(
              children: [
                FlutterMap(
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
                          .map((marker) => Marker(
                                point: marker,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red[900],
                                  size: MediaQuery.of(context).size.width * 0.1,
                                ),
                              ))
                          .toList(),
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.polyline,
                          strokeWidth: 5.0,
                          color: Colors.blue[400]!,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                context
                                    .read<MapBloc>()
                                    .add(SearchLocationEvent(value));
                              }
                            },
                            style: const TextStyle(color: Colors.white70),
                            decoration: InputDecoration(
                              hintText: 'Search location...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            context
                                .read<MapBloc>()
                                .add(SearchLocationEvent(""));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.suggestions.isNotEmpty)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.12,
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: state.suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = state.suggestions[index];
                          return ListTile(
                            title: Text(
                              suggestion['place_name'],
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            onTap: () {
                              final location = LatLng(
                                suggestion['geometry']['coordinates'][1],
                                suggestion['geometry']['coordinates'][0],
                              );
                              context
                                  .read<MapBloc>()
                                  .add(AddMarkerEvent(location));
                            },
                          );
                        },
                      ),
                    ),
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
