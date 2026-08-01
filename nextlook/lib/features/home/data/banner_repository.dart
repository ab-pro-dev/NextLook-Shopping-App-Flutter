import '../../../core/network/dio_client.dart';
import 'models/banner_model.dart';

class BannerRepository {
  final DioClient _dioClient;

  BannerRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Fetches active promotional banners from GET /api/banners.
  Future<List<BannerModel>> getBanners() async {
    final response = await _dioClient.dio.get('/api/banners');
    final list = (response.data as List<dynamic>)
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }
}
