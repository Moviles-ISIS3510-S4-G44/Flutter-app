import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/services/interaction_service.dart';

class InteractionRepository {
  final InteractionService _interactionService;
  final AuthRepository _authRepository;

  InteractionRepository({
    required InteractionService interactionService,
    required AuthRepository authRepository,
  })  : _interactionService = interactionService,
        _authRepository = authRepository;

  Future<void> registerInteraction({
    required String listingId,
  }) async {
    final accessToken = await _authRepository.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No access token found');
    }

    await _interactionService.registerInteraction(
      accessToken: accessToken,
      listingId: listingId,
    );
  }

  Future<List<String>> getTopInteractedListingIds() async {
    final user = await _authRepository.getMyProfile();

    final interactions = await _interactionService.getTopUserInteractions(
      user.id,
    );

    return interactions.map((interaction) => interaction.listingId).toList();
  }
}