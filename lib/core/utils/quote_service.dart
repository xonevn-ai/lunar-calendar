import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote.dart';
import 'package:uuid/uuid.dart';

/// Quote Service
/// Provides random Vietnamese quotes for day detail screen
/// Now uses Hive storage for persistence
class QuoteService {
  static final Random _random = Random();
  static const String _quotesBoxName = 'quotes';
  static Box<Quote>? _quotesBox;
  static const Uuid _uuid = Uuid();
  
  // Default Vietnamese quotes (proverbs, wisdom, etc.)
  static const List<String> _defaultQuotes = [
    'Thời gian là vàng bạc, nhưng vàng bạc không mua được thời gian.',
    'Mỗi ngày là một cơ hội mới để bắt đầu lại.',
    'Hôm nay là ngày tốt nhất để làm những điều bạn muốn.',
    'Thời gian trôi qua nhanh như gió, hãy trân trọng từng khoảnh khắc.',
    'Ngày hôm nay là món quà, đó là lý do tại sao nó được gọi là hiện tại.',
    'Mỗi ngày mới là một trang sách trắng, hãy viết nên câu chuyện đẹp.',
    'Thời gian là thứ quý giá nhất mà chúng ta có.',
    'Hãy sống trọn vẹn từng ngày, vì ngày hôm qua đã qua và ngày mai chưa đến.',
    'Mỗi buổi sáng là một khởi đầu mới, đầy hy vọng và cơ hội.',
    'Thời gian không chờ đợi ai, hãy làm những gì bạn muốn ngay hôm nay.',
    'Ngày hôm nay là ngày quan trọng nhất trong cuộc đời bạn.',
    'Hãy biết ơn vì mỗi ngày mới, vì đó là cơ hội để sống tốt hơn.',
    'Thời gian là thầy dạy tốt nhất, nhưng nó giết tất cả học trò của mình.',
    'Mỗi ngày là một món quà, hãy mở nó với niềm vui và lòng biết ơn.',
    'Hãy sống như thể hôm nay là ngày cuối cùng của bạn.',
    'Thời gian là thứ duy nhất không thể mua lại được.',
    'Mỗi khoảnh khắc đều quý giá, hãy trân trọng nó.',
    'Ngày hôm nay là ngày tốt nhất để bắt đầu một điều gì đó mới.',
    'Thời gian trôi qua không bao giờ quay lại, hãy sống trọn vẹn.',
    'Mỗi ngày mới là một cơ hội để trở thành phiên bản tốt hơn của chính mình.',
  ];
  
  /// Initialize QuoteService with Hive storage
  static Future<void> init() async {
    if (_quotesBox == null) {
      _quotesBox = await Hive.openBox<Quote>(_quotesBoxName);
      
      // Load default quotes if box is empty
      if (_quotesBox!.isEmpty) {
        await _loadDefaultQuotes();
      }
    }
  }
  
  /// Load default quotes into Hive
  static Future<void> _loadDefaultQuotes() async {
    if (_quotesBox == null) return;
    
    for (final quoteText in _defaultQuotes) {
      final quote = Quote(
        id: _uuid.v4(),
        text: quoteText,
        isCustom: false,
      );
      await _quotesBox!.add(quote);
    }
  }
  
  /// Get all quotes
  static List<Quote> getAllQuotes() {
    if (_quotesBox == null) return [];
    return _quotesBox!.values.toList();
  }
  
  /// Get a random quote
  static String getRandomQuote() {
    if (_quotesBox == null || _quotesBox!.isEmpty) {
      // Fallback to default if not initialized
      return _defaultQuotes[_random.nextInt(_defaultQuotes.length)];
    }
    
    final quotes = _quotesBox!.values.toList();
    return quotes[_random.nextInt(quotes.length)].text;
  }
  
  /// Get quote based on current date (for consistency)
  static String getQuoteForDate(DateTime date) {
    if (_quotesBox == null || _quotesBox!.isEmpty) {
      // Fallback to default if not initialized
      final seed = date.year * 10000 + date.month * 100 + date.day;
      final random = Random(seed);
      return _defaultQuotes[random.nextInt(_defaultQuotes.length)];
    }
    
    // Use date as seed for consistent quote per day
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    final quotes = _quotesBox!.values.toList();
    return quotes[random.nextInt(quotes.length)].text;
  }
  
  /// Add a custom quote
  static Future<void> addQuote(String text, {String? author}) async {
    if (_quotesBox == null) {
      await init();
    }
    
    final quote = Quote(
      id: _uuid.v4(),
      text: text,
      author: author,
      isCustom: true,
    );
    await _quotesBox!.add(quote);
  }
  
  /// Delete a quote
  static Future<void> deleteQuote(String id) async {
    if (_quotesBox == null) return;
    
    final quote = _quotesBox!.values.firstWhere(
      (q) => q.id == id,
      orElse: () => throw Exception('Quote not found'),
    );
    await quote.delete();
  }
  
  /// Get quotes box (for direct access if needed)
  static Box<Quote>? getQuotesBox() => _quotesBox;
}

