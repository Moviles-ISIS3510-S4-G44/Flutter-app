// temp mock analytics, just prints stuff to console
// delete when firebase is set up
class MockAnalyticsService {
  Future<void> logLogin(String method) async {
    print('[analytics] login: $method');
  }

  Future<void> logSignUp(String method) async {
    print('[analytics] signup: $method');
  }

  Future<void> logViewProduct(String productId, String productName) async {
    print('[analytics] view_product: $productId - $productName');
  }

  Future<void> logSearch(String query) async {
    print('[analytics] search: $query');
  }

  Future<void> logCreateListing(String productId, double price) async {
    print('[analytics] create_listing: $productId \$$price');
  }

  Future<void> logViewMap() async {
    print('[analytics] view_map');
  }

  Future<void> logViewMapProduct(String productId, double lat, double lng) async {
    print('[analytics] view_map_product: $productId at $lat,$lng');
  }

  Future<void> logUploadPhoto() async {
    print('[analytics] upload_profile_photo');
  }

  Future<void> logViewProfile(String userId) async {
    print('[analytics] view_profile: $userId');
  }

  Future<void> logScreenView(String screenName) async {
    print('[analytics] screen: $screenName');
  }

  Future<void> setUserId(String uid) async {
    print('[analytics] setUserId: $uid');
  }
}
