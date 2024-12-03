part of 'map_bloc.dart';

@immutable
sealed class MapState {}

final class MapInitial extends MapState {}

final class MapLoaded extends MapState {
  final LatLng center;
  final String urlTemplate;
  final String accessToken;
  final List<LatLng> markers;
  final List<LatLng> polyline;
  final List<dynamic> suggestions;

  MapLoaded(
    this.center,
    this.urlTemplate,
    this.accessToken, [
    this.markers = const [],
    this.polyline = const [],
    this.suggestions = const [],
  ]);

  MapLoaded copyWith({
    LatLng? center,
    String? urlTemplate,
    String? accessToken,
    List<LatLng>? markers,
    List<LatLng>? polyline,
    List<dynamic>? suggestions,
  }) {
    return MapLoaded(
      center ?? this.center,
      urlTemplate ?? this.urlTemplate,
      accessToken ?? this.accessToken,
      markers ?? this.markers,
      polyline ?? this.polyline,
      suggestions ?? this.suggestions,
    );
  }
}
