import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<LoadMapEvent>(
      (event, emit) async {
        try {
          Position position = await _getUserLocation();
          final userLocation = LatLng(position.latitude, position.longitude);

          emit(MapLoaded(
            userLocation,
            'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia2FybG9kZXYiLCJhIjoiY2xocTN1ZnVjMjB1NDNtcHNoMmI2N2dhcCJ9.5Y8fh8aPfM6f5zDKA_bDiw',
            'pk.eyJ1Ijoia2FybG9kZXYiLCJhIjoiY2xocTN1ZnVjMjB1NDNtcHNoMmI2N2dhcCJ9.5Y8fh8aPfM6f5zDKA_bDiw',
            [userLocation],
          ));
        } catch (e) {
          // ignore: avoid_print
          print("Error loading map: $e");
        }
      },
    );

    on<AddMarkerEvent>(
      (event, emit) async {
        if (state is MapLoaded) {
          final currentState = state as MapLoaded;
          final updatedMarkers = List<LatLng>.from(currentState.markers)
            ..add(event.location);

          emit(currentState.copyWith(markers: updatedMarkers));

          if (updatedMarkers.length > 1) {
            await getRouteForAllMarkers(updatedMarkers, emit);
          }
        }
      },
    );

    on<SearchLocationEvent>(
      (event, emit) async {
        try {
          final url =
              'https://api.mapbox.com/geocoding/v5/mapbox.places/${event.query}.json?access_token=pk.eyJ1Ijoia2FybG9kZXYiLCJhIjoiY2xocTN1ZnVjMjB1NDNtcHNoMmI2N2dhcCJ9.5Y8fh8aPfM6f5zDKA_bDiw';

          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final suggestions = data['features'];

            emit((state as MapLoaded).copyWith(suggestions: suggestions));
          } else {
            // ignore: avoid_print
            print("Failed to fetch locations: ${response.statusCode}");
          }
        } catch (e) {
          // ignore: avoid_print
          print("Error searching location: $e");
        }
      },
    );
  }

  Future<void> getRouteForAllMarkers(
      List<LatLng> markers, Emitter<MapState> emit) async {
    if (markers.length < 2) return;

    final coordinates = markers
        .map((marker) => '${marker.longitude},${marker.latitude}')
        .join(';');

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates?access_token=pk.eyJ1Ijoia2FybG9kZXYiLCJhIjoiY2xocTN1ZnVjMjB1NDNtcHNoMmI2N2dhcCJ9.5Y8fh8aPfM6f5zDKA_bDiw&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0]['geometry']['coordinates'] as List;

        final polylinePoints =
            route.map((point) => LatLng(point[1], point[0])).toList();

        emit((state as MapLoaded).copyWith(polyline: polylinePoints));
      } else {
        // ignore: avoid_print
        print("Failed to load route: ${response.statusCode}");
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error getting route: $e");
    }
  }

  Future<Position> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high);
  }
}
