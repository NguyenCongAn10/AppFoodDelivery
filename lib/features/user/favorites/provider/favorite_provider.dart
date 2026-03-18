import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final BackendService _backendService = BackendService();
  List<FoodModel> _favorites = [];
  bool _isLoading = false;

  List<FoodModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      _favorites = await _backendService.getFavorites();
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int foodId) {
    return _favorites.any((f) => f.id == foodId);
  }

  Future<void> toggleFavorite(FoodModel food) async {
    final bool currentlyFavorite = isFavorite(food.id);
    
    // Optimistic UI update
    if (currentlyFavorite) {
      _favorites.removeWhere((f) => f.id == food.id);
    } else {
      _favorites.add(food);
    }
    notifyListeners();

    try {
      await _backendService.toggleFavorite(food.id);
      // We don't necessarily need to reload from server if we trust the toggle
      // but let's do a silent reload to stay in sync just in case
      // _favorites = await _backendService.getFavorites();
      // notifyListeners();
    } catch (e) {
      // Rollback on error
      if (currentlyFavorite) {
        _favorites.add(food);
      } else {
        _favorites.removeWhere((f) => f.id == food.id);
      }
      notifyListeners();
      debugPrint("Error toggling favorite: $e");
      rethrow;
    }
  }
}
