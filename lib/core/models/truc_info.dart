/// Trực (Day Quality) type
enum TrucType {
  hoangdao,
  hacdao,
}

/// Trực information
class TrucInfo {
  final String id;
  final String name;
  final TrucType type;
  final List<String> goodFor;
  final List<String> badFor;

  const TrucInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.goodFor,
    required this.badFor,
  });
}

