import 'dart:math';

/// Background Image Service
/// Provides random background images for calendar views
class BackgroundService {
  static final Random _random = Random();
  
  // List of background image URLs (using placeholder images for now)
  // In production, these would be actual image URLs or local assets
  static const List<String> _backgroundImages = [
    // Vietnamese landscape images
    'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
    'https://images.unsplash.com/photo-1511497584788-876760111969?w=800',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800',
  ];
  
  /// Get a random background image URL
  static String getRandomBackground() {
    return _backgroundImages[_random.nextInt(_backgroundImages.length)];
  }
  
  /// Get background image based on current date (for consistency)
  static String getBackgroundForDate(DateTime date) {
    // Use date as seed for consistent background per day
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    return _backgroundImages[random.nextInt(_backgroundImages.length)];
  }
}

