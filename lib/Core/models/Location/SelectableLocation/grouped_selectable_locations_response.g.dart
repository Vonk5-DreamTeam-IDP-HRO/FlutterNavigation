// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grouped_selectable_locations_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupedSelectableLocationsResponse
_$GroupedSelectableLocationsResponseFromJson(
  Map<String, dynamic> json,
) => _GroupedSelectableLocationsResponse(
  groupedLocations: (json['groupedLocations'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => SelectableLocationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$GroupedSelectableLocationsResponseToJson(
  _GroupedSelectableLocationsResponse instance,
) => <String, dynamic>{'groupedLocations': instance.groupedLocations};
