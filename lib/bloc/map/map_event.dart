part of 'map_bloc.dart';

@immutable
sealed class MapEvent {}

class LoadMapEvent extends MapEvent {}

class AddMarkerEvent extends MapEvent {
  final LatLng location;

  AddMarkerEvent(this.location);
}
