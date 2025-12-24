/// Can Chi (Stem-Branch) models
import 'element.dart';

/// Thiên Can (Heavenly Stem)
class ThienCan {
  final int index; // 0-9
  final String name; // Giáp, Ất, Bính...
  final Element element;
  final bool yin; // true = Âm, false = Dương

  const ThienCan({
    required this.index,
    required this.name,
    required this.element,
    required this.yin,
  });
}

/// Địa Chi (Earthly Branch)
class DiaChi {
  final int index; // 0-11
  final String name; // Tý, Sửu, Dần...
  final String animal; // Con giáp
  final Element element;

  const DiaChi({
    required this.index,
    required this.name,
    required this.animal,
    required this.element,
  });
}

/// Can Chi combination
class CanChi {
  final int can; // Thiên Can index (0-9)
  final int chi; // Địa Chi index (0-11)
  final String canName;
  final String chiName;
  final String fullName; // "Giáp Tý"
  final Element element;
  final String? napAm; // Nạp Âm (nếu có)

  const CanChi({
    required this.can,
    required this.chi,
    required this.canName,
    required this.chiName,
    required this.fullName,
    required this.element,
    this.napAm,
  });
}

