import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../data/banner_repository.dart';
import '../data/models/banner_model.dart';

/// Provider for BannerRepository instance.
final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BannerRepository(dioClient: dioClient);
});

/// FutureProvider for fetching active Banners.
final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final repo = ref.watch(bannerRepositoryProvider);
  return await repo.getBanners();
});
