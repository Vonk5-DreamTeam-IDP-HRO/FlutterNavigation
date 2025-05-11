// For jsonEncode in mock responses
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:osm_navigation/core/config/app_config.dart';
import 'package:osm_navigation/core/services/location_api_service.dart';
import 'package:osm_navigation/core/models/selectable_location.dart';
import 'package:osm_navigation/core/services/location_api_exceptions.dart';

@GenerateMocks([Dio])
import 'location_api_service_test.mocks.dart'; // Will be generated

void main() {
  late LocationApiService service;
  late MockDio mockDio;

  const String locationsEndpoint = 'locations';
  const String detailsEndpoint = 'location_details';

  late String fullLocationsUrl;
  late String fullDetailsUrl;

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'tempREST_API_URL=http://fake-test-api.com');
    await AppConfig.load();
    fullLocationsUrl = '${AppConfig.tempRESTUrl}/$locationsEndpoint';
    fullDetailsUrl = '${AppConfig.tempRESTUrl}/$detailsEndpoint';
  });

  setUp(() {
    mockDio = MockDio();
    service = LocationApiService(mockDio);
  });

  Response<List<dynamic>> createSuccessResponse(
    List<dynamic> data,
    String fullRequestPath,
  ) {
    return Response(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: fullRequestPath),
    );
  }

  DioException createDioError({
    required int statusCode,
    required String fullRequestPath,
    String? statusMessage,
    dynamic data,
  }) {
    return DioException(
      response: Response(
        data: data ?? {'message': 'Error'},
        statusCode: statusCode,
        statusMessage: statusMessage ?? 'Error',
        requestOptions: RequestOptions(path: fullRequestPath),
      ),
      requestOptions: RequestOptions(path: fullRequestPath),
      type: DioExceptionType.badResponse,
    );
  }

  DioException createTimeoutDioError(String fullRequestPath) {
    return DioException(
      requestOptions: RequestOptions(path: fullRequestPath),
      type: DioExceptionType.connectionTimeout,
      message: 'Connection timed out',
    );
  }

/*
  group('LocationApiService - getGroupedSelectableLocations', () {
    final mockLocationsJson = [
      {'locationid': 1, 'name': 'Location Alpha'},
      {'locationid': 2, 'name': 'Location Beta'},
      {'locationid': 3, 'name': 'Location Gamma'},
    ];
    final mockDetailsJson = [
      {'locationId': 1, 'category': 'Category One'},
      {'locationId': 2, 'category': 'Category Two'},
    ];

    test('returns grouped locations on successful API calls', () async {
      when(mockDio.get(fullLocationsUrl)).thenAnswer(
        (_) async => createSuccessResponse(mockLocationsJson, fullLocationsUrl),
      );
      when(mockDio.get(fullDetailsUrl)).thenAnswer(
        (_) async => createSuccessResponse(mockDetailsJson, fullDetailsUrl),
      );

      final result = await service.getGroupedSelectableLocations();

      expect(result, isA<Map<String, List<SelectableLocation>>>());
      expect(
        result.keys,
        containsAll(['Category One', 'Category Two', 'Uncategorized']),
      );
      expect(result['Category One']?.length, 1);
      expect(result['Category One']?[0].name, 'Location Alpha');
      expect(result['Category Two']?.length, 1);
      expect(result['Category Two']?[0].name, 'Location Beta');
      expect(result['Uncategorized']?.length, 1);
      expect(result['Uncategorized']?[0].name, 'Location Gamma');

      verify(mockDio.get(fullLocationsUrl)).called(1);
      verify(mockDio.get(fullDetailsUrl)).called(1);
    });

    test(
      'throws LocationApiNetworkException if locations API call fails',
      () async {
        when(mockDio.get(fullLocationsUrl)).thenThrow(
          createDioError(
            statusCode: 404,
            fullRequestPath: fullLocationsUrl,
            statusMessage: 'Not Found',
          ),
        );
        when(mockDio.get(fullDetailsUrl)).thenAnswer(
          // This might not be called if Future.wait short-circuits
          (_) async => createSuccessResponse(mockDetailsJson, fullDetailsUrl),
        );

        expect(
          () => service.getGroupedSelectableLocations(),
          throwsA(
            isA<LocationApiNetworkException>()
                .having((e) => e.statusCode, 'statusCode', 404)
                .having(
                  (e) => e.message,
                  'message',
                  contains('Network error during fetching locations'),
                ),
          ),
        );
        verify(mockDio.get(fullLocationsUrl)).called(1);
        // verifyNever(mockDio.get(fullDetailsUrl)); // Future.wait behavior can vary
      },
    );

    test(
      'throws LocationApiNetworkException if details API call fails',
      () async {
        when(mockDio.get(fullLocationsUrl)).thenAnswer(
          (_) async =>
              createSuccessResponse(mockLocationsJson, fullLocationsUrl),
        );
        when(mockDio.get(fullDetailsUrl)).thenThrow(
          createDioError(
            statusCode: 500,
            fullRequestPath: fullDetailsUrl,
            statusMessage: 'Server Error',
          ),
        );

        expect(
          () => service.getGroupedSelectableLocations(),
          throwsA(
            isA<LocationApiNetworkException>()
                .having((e) => e.statusCode, 'statusCode', 500)
                .having(
                  (e) => e.message,
                  'message',
                  contains('Network error during fetching location details'),
                ),
          ),
        );
        verify(mockDio.get(fullLocationsUrl)).called(1);
        verify(mockDio.get(fullDetailsUrl)).called(1);
      },
    );

    test(
      'throws LocationApiNetworkException on timeout for locations API',
      () async {
        when(
          mockDio.get(fullLocationsUrl),
        ).thenThrow(createTimeoutDioError(fullLocationsUrl));
        when(mockDio.get(fullDetailsUrl)).thenAnswer(
          (_) async => createSuccessResponse(mockDetailsJson, fullDetailsUrl),
        );

        expect(
          () => service.getGroupedSelectableLocations(),
          throwsA(
            isA<LocationApiNetworkException>().having(
              (e) => e.message,
              'message',
              contains('Request timed out during fetching locations'),
            ),
          ),
        );
      },
    );

    test(
      'throws LocationApiParseException if locations response is not a list',
      () async {
        when(mockDio.get(fullLocationsUrl)).thenAnswer(
          (_) async => Response(
            data: {'not': 'a list'},
            statusCode: 200,
            requestOptions: RequestOptions(path: fullLocationsUrl),
          ),
        );
        when(mockDio.get(fullDetailsUrl)).thenAnswer(
          (_) async => createSuccessResponse(mockDetailsJson, fullDetailsUrl),
        );

        expect(
          () => service.getGroupedSelectableLocations(),
          throwsA(
            isA<LocationApiParseException>().having(
              (e) => e.message,
              'message',
              'Invalid format for locations: Expected a List.',
            ),
          ),
        );
      },
    );

    test('handles empty list from locations API correctly', () async {
      when(
        mockDio.get(fullLocationsUrl),
      ).thenAnswer((_) async => createSuccessResponse([], fullLocationsUrl));
      when(mockDio.get(fullDetailsUrl)).thenAnswer(
        (_) async => createSuccessResponse(mockDetailsJson, fullDetailsUrl),
      );

      final result = await service.getGroupedSelectableLocations();
      expect(result, isA<Map<String, List<SelectableLocation>>>());
      expect(result.isEmpty, isTrue);
    });

    test(
      'handles empty list from details API correctly (all locations uncategorized)',
      () async {
        when(mockDio.get(fullLocationsUrl)).thenAnswer(
          (_) async =>
              createSuccessResponse(mockLocationsJson, fullLocationsUrl),
        );
        when(
          mockDio.get(fullDetailsUrl),
        ).thenAnswer((_) async => createSuccessResponse([], fullDetailsUrl));

        final result = await service.getGroupedSelectableLocations();
        expect(result.keys, contains('Uncategorized'));
        expect(result['Uncategorized']?.length, mockLocationsJson.length);
      },
    );

    test('handles location data with missing id or name gracefully', () async {
      final faultyLocationsJson = [
        {'locationid': 1, 'name': 'Location Alpha'},
        {'name': 'Location Missing ID'},
        {'locationid': 3},
        {'locationid': 4, 'name': 'Location Delta'},
      ];
      when(mockDio.get(fullLocationsUrl)).thenAnswer(
        (_) async =>
            createSuccessResponse(faultyLocationsJson, fullLocationsUrl),
      );
      when(mockDio.get(fullDetailsUrl)).thenAnswer(
        (_) async => createSuccessResponse(mockDetailsJson, fullDetailsUrl),
      );

      final result = await service.getGroupedSelectableLocations();
      expect(result['Category One']?.length, 1);
      expect(result['Category One']?[0].name, 'Location Alpha');
      expect(result['Uncategorized']?.length, 1);
      expect(result['Uncategorized']?[0].name, 'Location Delta');
      expect(result.values.expand((list) => list).length, 2);
    });
  });
*/
}
