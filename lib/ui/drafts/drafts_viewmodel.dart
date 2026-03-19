import 'package:flutter/foundation.dart';

class DraftsViewModel extends ChangeNotifier {
  List<Map<String, String>> drafts = [];
  bool isLoading = false;

  Future<void> loadDrafts() async {
    isLoading = true;
    notifyListeners();

    // saved in memory for now, later could use shared prefs or sqflite
    await Future.delayed(const Duration(milliseconds: 100));

    isLoading = false;
    notifyListeners();
  }

  void saveDraft({
    required String title,
    required String description,
    required String price,
    required String category,
  }) {
    drafts = [
      ...drafts,
      {
        'title': title,
        'description': description,
        'price': price,
        'category': category,
      },
    ];
    notifyListeners();
  }

  void deleteDraft(int index) {
    if (index < 0 || index >= drafts.length) return;
    drafts = [...drafts]..removeAt(index);
    notifyListeners();
  }
}
