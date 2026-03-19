import 'package:firebase_analytics/firebase_analytics.dart';

/// Handles all analytics event logging
///
/// Event taxonomy for our BQs:
/// - login / signup -> BQ1: how many students are inactive
/// - view_product / search -> BQ2: what are most searched categories
/// - create_listing -> BQ3: how often do students post listings
/// - view_map -> BQ4: where are most transactions happening
/// - upload_photo -> BQ5: do users with photos get more engagement
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // auth events
  Future<void> logLogin(String method) {
    return _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) {
    return _analytics.logSignUp(signUpMethod: method);
  }

  // product events
  Future<void> logViewProduct(String productId, String productName) {
    return _analytics.logEvent(
      name: 'view_product',
      parameters: {
        'product_id': productId,
        'product_name': productName,
      },
    );
  }

  Future<void> logSearch(String query) {
    return _analytics.logSearch(searchTerm: query);
  }

  Future<void> logCreateListing(String productId, double price) {
    return _analytics.logEvent(
      name: 'create_listing',
      parameters: {
        'product_id': productId,
        'price': price,
      },
    );
  }

  // map events
  Future<void> logViewMap() {
    return _analytics.logEvent(name: 'view_map');
  }

  Future<void> logViewMapProduct(String productId, double lat, double lng) {
    return _analytics.logEvent(
      name: 'view_map_product',
      parameters: {
        'product_id': productId,
        'latitude': lat,
        'longitude': lng,
      },
    );
  }

  // profile events
  Future<void> logUploadPhoto() {
    return _analytics.logEvent(name: 'upload_profile_photo');
  }

  Future<void> logViewProfile(String userId) {
    return _analytics.logEvent(
      name: 'view_profile',
      parameters: {'user_id': userId},
    );
  }

  // screen tracking
  Future<void> logScreenView(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  // set user props for segmentation
  Future<void> setUserId(String uid) {
    return _analytics.setUserId(id: uid);
  }
}
