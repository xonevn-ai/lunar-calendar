/// Constants for Vietnamese Lunar Calendar
import 'models/can_chi.dart';
import 'models/element.dart';
import 'models/truc_info.dart';
import 'models/solar_term.dart';
import 'models/calendar_date.dart';

/// Thiên Can (Heavenly Stems)
const List<ThienCan> thienCan = [
  ThienCan(index: 0, name: 'Giáp', element: Element.moc, yin: false),
  ThienCan(index: 1, name: 'Ất', element: Element.moc, yin: true),
  ThienCan(index: 2, name: 'Bính', element: Element.hoa, yin: false),
  ThienCan(index: 3, name: 'Đinh', element: Element.hoa, yin: true),
  ThienCan(index: 4, name: 'Mậu', element: Element.tho, yin: false),
  ThienCan(index: 5, name: 'Kỷ', element: Element.tho, yin: true),
  ThienCan(index: 6, name: 'Canh', element: Element.kim, yin: false),
  ThienCan(index: 7, name: 'Tân', element: Element.kim, yin: true),
  ThienCan(index: 8, name: 'Nhâm', element: Element.thuy, yin: false),
  ThienCan(index: 9, name: 'Quý', element: Element.thuy, yin: true),
];

/// Địa Chi (Earthly Branches)
const List<DiaChi> diaChi = [
  DiaChi(index: 0, name: 'Tý', animal: 'Chuột', element: Element.thuy),
  DiaChi(index: 1, name: 'Sửu', animal: 'Trâu', element: Element.tho),
  DiaChi(index: 2, name: 'Dần', animal: 'Hổ', element: Element.moc),
  DiaChi(index: 3, name: 'Mão', animal: 'Mão', element: Element.moc),
  DiaChi(index: 4, name: 'Thìn', animal: 'Rồng', element: Element.tho),
  DiaChi(index: 5, name: 'Tỵ', animal: 'Rắn', element: Element.hoa),
  DiaChi(index: 6, name: 'Ngọ', animal: 'Ngựa', element: Element.hoa),
  DiaChi(index: 7, name: 'Mùi', animal: 'Dê', element: Element.tho),
  DiaChi(index: 8, name: 'Thân', animal: 'Khỉ', element: Element.kim),
  DiaChi(index: 9, name: 'Dậu', animal: 'Gà', element: Element.kim),
  DiaChi(index: 10, name: 'Tuất', animal: 'Chó', element: Element.tho),
  DiaChi(index: 11, name: 'Hợi', animal: 'Heo', element: Element.thuy),
];

/// Tên tháng âm lịch
const List<String> lunarMonthNames = [
  'Giêng',
  'Hai',
  'Ba',
  'Tư',
  'Năm',
  'Sáu',
  'Bảy',
  'Tám',
  'Chín',
  'Mười',
  'Mười một',
  'Chạp',
];

/// Supported year range
const int minYear = 1900;
const int maxYear = 2100;

/// Julian day for 1900-01-01
const double julian1900Jan1 = 2415021.0;

/// Nạp Âm (60-year cycle elements)
class NapAmInfo {
  final String name;
  final Element element;

  const NapAmInfo({required this.name, required this.element});
}

const List<NapAmInfo> napAm = [
  NapAmInfo(name: 'Hải Trung Kim', element: Element.kim),
  NapAmInfo(name: 'Lô Trung Hỏa', element: Element.hoa),
  NapAmInfo(name: 'Đại Lâm Mộc', element: Element.moc),
  NapAmInfo(name: 'Lộ Bàng Thổ', element: Element.tho),
  NapAmInfo(name: 'Kiếm Phong Kim', element: Element.kim),
  NapAmInfo(name: 'Sơn Đầu Hỏa', element: Element.hoa),
  NapAmInfo(name: 'Giản Hạ Thủy', element: Element.thuy),
  NapAmInfo(name: 'Thành Đầu Thổ', element: Element.tho),
  NapAmInfo(name: 'Bạch Lạp Kim', element: Element.kim),
  NapAmInfo(name: 'Dương Liễu Mộc', element: Element.moc),
  NapAmInfo(name: 'Tuyền Trung Thủy', element: Element.thuy),
  NapAmInfo(name: 'Ốc Thượng Thổ', element: Element.tho),
  NapAmInfo(name: 'Tích Lịch Hỏa', element: Element.hoa),
  NapAmInfo(name: 'Tùng Bách Mộc', element: Element.moc),
  NapAmInfo(name: 'Trường Lưu Thủy', element: Element.thuy),
  NapAmInfo(name: 'Sa Trung Kim', element: Element.kim),
  NapAmInfo(name: 'Sơn Hạ Hỏa', element: Element.hoa),
  NapAmInfo(name: 'Bình Địa Mộc', element: Element.moc),
  NapAmInfo(name: 'Bích Thượng Thổ', element: Element.tho),
  NapAmInfo(name: 'Kim Bạch Kim', element: Element.kim),
  NapAmInfo(name: 'Phúc Đăng Hỏa', element: Element.hoa),
  NapAmInfo(name: 'Thiên Hà Thủy', element: Element.thuy),
  NapAmInfo(name: 'Đại Trạch Thổ', element: Element.tho),
  NapAmInfo(name: 'Thoa Xuyến Kim', element: Element.kim),
  NapAmInfo(name: 'Tang Đố Mộc', element: Element.moc),
  NapAmInfo(name: 'Đại Khê Thủy', element: Element.thuy),
  NapAmInfo(name: 'Sa Trung Thổ', element: Element.tho),
  NapAmInfo(name: 'Thiên Thượng Hỏa', element: Element.hoa),
  NapAmInfo(name: 'Thạch Lựu Mộc', element: Element.moc),
  NapAmInfo(name: 'Đại Hải Thủy', element: Element.thuy),
];

/// Hoàng Đạo Stars (12 stars for hours)
class HoangDaoStar {
  final String name;
  final String type; // 'hoangdao' or 'hacdao'
  final String meaning;

  const HoangDaoStar({
    required this.name,
    required this.type,
    required this.meaning,
  });
}

const List<HoangDaoStar> hoangDaoStars = [
  HoangDaoStar(name: 'Thanh Long', type: 'hoangdao', meaning: 'Cát tinh mang lại sự hanh thông'),
  HoangDaoStar(name: 'Minh Đường', type: 'hoangdao', meaning: 'Sáng suốt, thuận lợi ký kết'),
  HoangDaoStar(name: 'Thiên Hình', type: 'hacdao', meaning: 'Không thuận cho kiện tụng, tranh chấp'),
  HoangDaoStar(name: 'Chu Tước', type: 'hacdao', meaning: 'Dễ gặp khẩu thiệt, thị phi'),
  HoangDaoStar(name: 'Kim Quỹ', type: 'hoangdao', meaning: 'Tài lộc, tốt cho cưới hỏi'),
  HoangDaoStar(name: 'Thiên Đức', type: 'hoangdao', meaning: 'Phúc đức, tốt cho cầu tài'),
  HoangDaoStar(name: 'Bạch Hổ', type: 'hacdao', meaning: 'Hung sát, tránh động thổ'),
  HoangDaoStar(name: 'Ngọc Đường', type: 'hoangdao', meaning: 'Cát tường, tốt cho khai trương'),
  HoangDaoStar(name: 'Thiên Lao', type: 'hacdao', meaning: 'Trở ngại, dễ gặp ràng buộc pháp lý'),
  HoangDaoStar(name: 'Huyền Vũ', type: 'hacdao', meaning: 'Hung tinh, tránh đi xa'),
  HoangDaoStar(name: 'Tư Mệnh', type: 'hoangdao', meaning: 'Bảo hộ, tốt cho mọi việc lớn'),
  HoangDaoStar(name: 'Câu Trần', type: 'hacdao', meaning: 'Trì trệ, dễ gặp trở ngại'),
];

/// Hour star start table (based on day's Chi)
const List<int> hourStarStartTable = [0, 2, 4, 6, 8, 10, 0, 2, 4, 6, 8, 10];

/// Trực Info (12 day qualities)
const List<TrucInfo> trucInfo = [
  TrucInfo(
    id: 'kien',
    name: 'Kiến',
    type: TrucType.hacdao,
    goodFor: ['Xuất hành', 'Khai trương nhỏ'],
    badFor: ['Khai trương lớn', 'Động thổ'],
  ),
  TrucInfo(
    id: 'tru',
    name: 'Trừ',
    type: TrucType.hoangdao,
    goodFor: ['Trừ tà', 'Tảo mộ'],
    badFor: ['Cưới hỏi'],
  ),
  TrucInfo(
    id: 'man',
    name: 'Mãn',
    type: TrucType.hacdao,
    goodFor: ['Thụ lộc'],
    badFor: ['Động thổ', 'Xây dựng'],
  ),
  TrucInfo(
    id: 'binh',
    name: 'Bình',
    type: TrucType.hacdao,
    goodFor: ['Việc nhỏ'],
    badFor: ['Ký kết quan trọng'],
  ),
  TrucInfo(
    id: 'dinh',
    name: 'Định',
    type: TrucType.hoangdao,
    goodFor: ['Cưới hỏi', 'Ký kết'],
    badFor: ['Tranh chấp'],
  ),
  TrucInfo(
    id: 'chap',
    name: 'Chấp',
    type: TrucType.hoangdao,
    goodFor: ['Xây dựng', 'Gieo trồng'],
    badFor: ['Chuyển nhà'],
  ),
  TrucInfo(
    id: 'pha',
    name: 'Phá',
    type: TrucType.hacdao,
    goodFor: ['Phá dỡ'],
    badFor: ['Mọi việc quan trọng'],
  ),
  TrucInfo(
    id: 'nguy',
    name: 'Nguy',
    type: TrucType.hacdao,
    goodFor: ['Cúng tế'],
    badFor: ['Khai trương', 'Cưới hỏi'],
  ),
  TrucInfo(
    id: 'thanh',
    name: 'Thành',
    type: TrucType.hoangdao,
    goodFor: ['Hoàn thiện công việc', 'Động thổ'],
    badFor: ['Kiện tụng'],
  ),
  TrucInfo(
    id: 'thu',
    name: 'Thu',
    type: TrucType.hacdao,
    goodFor: ['Thu hoạch'],
    badFor: ['Xây dựng'],
  ),
  TrucInfo(
    id: 'khai',
    name: 'Khai',
    type: TrucType.hoangdao,
    goodFor: ['Khai trương', 'Mở kho'],
    badFor: ['An táng'],
  ),
  TrucInfo(
    id: 'be',
    name: 'Bế',
    type: TrucType.hacdao,
    goodFor: ['Đóng cửa kho'],
    badFor: ['Khởi công', 'Cưới hỏi'],
  ),
];

/// 24 Solar Terms (Tiết Khí) - Base definitions
/// Note: Actual dates are calculated per year
const List<SolarTerm> solarTermsBase = [
  SolarTerm(
    index: 0,
    name: 'Tiểu Hàn',
    chineseName: '小寒',
    date: SolarDate(year: 0, month: 1, day: 5),
    description: 'Thời tiết se lạnh, chuẩn bị cho Đại Hàn.',
  ),
  SolarTerm(
    index: 1,
    name: 'Đại Hàn',
    chineseName: '大寒',
    date: SolarDate(year: 0, month: 1, day: 20),
    description: 'Giai đoạn lạnh nhất trong năm.',
  ),
  SolarTerm(
    index: 2,
    name: 'Lập Xuân',
    chineseName: '立春',
    date: SolarDate(year: 0, month: 2, day: 4),
    description: 'Bắt đầu mùa xuân.',
  ),
  SolarTerm(
    index: 3,
    name: 'Vũ Thủy',
    chineseName: '雨水',
    date: SolarDate(year: 0, month: 2, day: 19),
    description: 'Mưa phùn xuất hiện, báo hiệu vụ mùa mới.',
  ),
  SolarTerm(
    index: 4,
    name: 'Kinh Trập',
    chineseName: '惊蛰',
    date: SolarDate(year: 0, month: 3, day: 5),
    description: 'Côn trùng tỉnh giấc sau mùa đông.',
  ),
  SolarTerm(
    index: 5,
    name: 'Xuân Phân',
    chineseName: '春分',
    date: SolarDate(year: 0, month: 3, day: 20),
    description: 'Ngày đêm bằng nhau.',
  ),
  SolarTerm(
    index: 6,
    name: 'Thanh Minh',
    chineseName: '清明',
    date: SolarDate(year: 0, month: 4, day: 4),
    description: 'Tiết trời trong sáng, tảo mộ.',
  ),
  SolarTerm(
    index: 7,
    name: 'Cốc Vũ',
    chineseName: '谷雨',
    date: SolarDate(year: 0, month: 4, day: 20),
    description: 'Mưa rào nuôi dưỡng mùa màng.',
  ),
  SolarTerm(
    index: 8,
    name: 'Lập Hạ',
    chineseName: '立夏',
    date: SolarDate(year: 0, month: 5, day: 5),
    description: 'Bắt đầu mùa hạ.',
  ),
  SolarTerm(
    index: 9,
    name: 'Tiểu Mãn',
    chineseName: '小满',
    date: SolarDate(year: 0, month: 5, day: 21),
    description: 'Lúa bắt đầu chắc hạt.',
  ),
  SolarTerm(
    index: 10,
    name: 'Mang Chủng',
    chineseName: '芒种',
    date: SolarDate(year: 0, month: 6, day: 6),
    description: 'Thời điểm gieo trồng các loại lúa có màng.',
  ),
  SolarTerm(
    index: 11,
    name: 'Hạ Chí',
    chineseName: '夏至',
    date: SolarDate(year: 0, month: 6, day: 21),
    description: 'Ngày dài nhất trong năm.',
  ),
  SolarTerm(
    index: 12,
    name: 'Tiểu Thử',
    chineseName: '小暑',
    date: SolarDate(year: 0, month: 7, day: 7),
    description: 'Bắt đầu nóng nực.',
  ),
  SolarTerm(
    index: 13,
    name: 'Đại Thử',
    chineseName: '大暑',
    date: SolarDate(year: 0, month: 7, day: 22),
    description: 'Thời điểm nóng nhất trong năm.',
  ),
  SolarTerm(
    index: 14,
    name: 'Lập Thu',
    chineseName: '立秋',
    date: SolarDate(year: 0, month: 8, day: 7),
    description: 'Bắt đầu mùa thu.',
  ),
  SolarTerm(
    index: 15,
    name: 'Xử Thử',
    chineseName: '处暑',
    date: SolarDate(year: 0, month: 8, day: 23),
    description: 'Nhiệt độ bắt đầu giảm.',
  ),
  SolarTerm(
    index: 16,
    name: 'Bạch Lộ',
    chineseName: '白露',
    date: SolarDate(year: 0, month: 9, day: 7),
    description: 'Sương trắng xuất hiện.',
  ),
  SolarTerm(
    index: 17,
    name: 'Thu Phân',
    chineseName: '秋分',
    date: SolarDate(year: 0, month: 9, day: 23),
    description: 'Ngày đêm bằng nhau lần hai.',
  ),
  SolarTerm(
    index: 18,
    name: 'Hàn Lộ',
    chineseName: '寒露',
    date: SolarDate(year: 0, month: 10, day: 8),
    description: 'Không khí chuyển lạnh.',
  ),
  SolarTerm(
    index: 19,
    name: 'Sương Giáng',
    chineseName: '霜降',
    date: SolarDate(year: 0, month: 10, day: 23),
    description: 'Sương mù, sương muối xuất hiện.',
  ),
  SolarTerm(
    index: 20,
    name: 'Lập Đông',
    chineseName: '立冬',
    date: SolarDate(year: 0, month: 11, day: 7),
    description: 'Bắt đầu mùa đông.',
  ),
  SolarTerm(
    index: 21,
    name: 'Tiểu Tuyết',
    chineseName: '小雪',
    date: SolarDate(year: 0, month: 11, day: 22),
    description: 'Bắt đầu có tuyết ở vùng ôn đới.',
  ),
  SolarTerm(
    index: 22,
    name: 'Đại Tuyết',
    chineseName: '大雪',
    date: SolarDate(year: 0, month: 12, day: 7),
    description: 'Tuyết rơi dày đặc.',
  ),
  SolarTerm(
    index: 23,
    name: 'Đông Chí',
    chineseName: '冬至',
    date: SolarDate(year: 0, month: 12, day: 21),
    description: 'Ngày ngắn nhất trong năm.',
  ),
];

/// Bành Tổ Bách Kỵ Nhật - Prohibitions based on Thiên Can
/// Source: Traditional Vietnamese calendar knowledge
const Map<String, Map<String, dynamic>> bangToCan = {
  'Giáp': {
    'prohibition': 'Bất khai khẩu, tất kiến họa',
    'vietnamese': 'Không nên mở miệng để tránh họa',
    'description': 'Ngày Giáp kỵ mở miệng, nói nhiều dễ gặp họa',
    'avoidActivities': ['Khai khẩu', 'Nói nhiều', 'Tranh luận'],
  },
  'Ất': {
    'prohibition': 'Bất tu táo, tất kiến hỏa ương',
    'vietnamese': 'Không nên sửa chữa bếp để tránh hỏa tai',
    'description': 'Ngày Ất kỵ sửa chữa bếp, dễ gặp hỏa hoạn',
    'avoidActivities': ['Sửa chữa bếp', 'Xây dựng bếp', 'Di chuyển bếp'],
  },
  'Bính': {
    'prohibition': 'Bất tu táo tất kiến hỏa ương',
    'vietnamese': 'Không nên tiến hành sửa chữa bếp để tránh bị hỏa tai',
    'description': 'Ngày Bính kỵ sửa chữa bếp, dễ gặp hỏa hoạn',
    'avoidActivities': ['Sửa chữa bếp', 'Xây dựng bếp', 'Di chuyển bếp'],
  },
  'Đinh': {
    'prohibition': 'Bất tu táo tất kiến hỏa ương',
    'vietnamese': 'Không nên sửa chữa bếp để tránh hỏa tai',
    'description': 'Ngày Đinh kỵ sửa chữa bếp, dễ gặp hỏa hoạn',
    'avoidActivities': ['Sửa chữa bếp', 'Xây dựng bếp'],
  },
  'Mậu': {
    'prohibition': 'Bất thổ địa, tất kiến họa',
    'vietnamese': 'Không nên đào đất để tránh họa',
    'description': 'Ngày Mậu kỵ đào đất, xây dựng',
    'avoidActivities': ['Đào đất', 'Xây dựng', 'Động thổ'],
  },
  'Kỷ': {
    'prohibition': 'Bất thổ địa, tất kiến họa',
    'vietnamese': 'Không nên đào đất để tránh họa',
    'description': 'Ngày Kỷ kỵ đào đất, xây dựng',
    'avoidActivities': ['Đào đất', 'Xây dựng', 'Động thổ'],
  },
  'Canh': {
    'prohibition': 'Bất tu kim, tất kiến họa',
    'vietnamese': 'Không nên sửa chữa đồ kim loại để tránh họa',
    'description': 'Ngày Canh kỵ sửa chữa đồ kim loại',
    'avoidActivities': ['Sửa chữa kim loại', 'Rèn đúc'],
  },
  'Tân': {
    'prohibition': 'Bất tu kim, tất kiến họa',
    'vietnamese': 'Không nên sửa chữa đồ kim loại để tránh họa',
    'description': 'Ngày Tân kỵ sửa chữa đồ kim loại',
    'avoidActivities': ['Sửa chữa kim loại', 'Rèn đúc'],
  },
  'Nhâm': {
    'prohibition': 'Bất tu thủy, tất kiến họa',
    'vietnamese': 'Không nên sửa chữa đường nước để tránh họa',
    'description': 'Ngày Nhâm kỵ sửa chữa đường nước',
    'avoidActivities': ['Sửa chữa đường nước', 'Đào giếng'],
  },
  'Quý': {
    'prohibition': 'Bất tu thủy, tất kiến họa',
    'vietnamese': 'Không nên sửa chữa đường nước để tránh họa',
    'description': 'Ngày Quý kỵ sửa chữa đường nước',
    'avoidActivities': ['Sửa chữa đường nước', 'Đào giếng'],
  },
};

/// Bành Tổ Bách Kỵ Nhật - Prohibitions based on Địa Chi
const Map<String, Map<String, dynamic>> bangToChi = {
  'Tý': {
    'prohibition': 'Bất tế tự quỷ thần bất thường',
    'vietnamese': 'Không nên tiến hành công việc liên quan đến tế tự vì ngày này quỷ thần không bình thường',
    'description': 'Ngày Tý kỵ tế tự, cúng bái',
    'avoidActivities': ['Tế tự', 'Cúng bái', 'Lễ nghi tôn giáo'],
  },
  'Sửu': {
    'prohibition': 'Bất tế tự quỷ thần bất thường',
    'vietnamese': 'Không nên tế tự vì quỷ thần không bình thường',
    'description': 'Ngày Sửu kỵ tế tự, cúng bái',
    'avoidActivities': ['Tế tự', 'Cúng bái'],
  },
  'Dần': {
    'prohibition': 'Bất tế tự quỷ thần bất thường',
    'vietnamese': 'Không nên tiến hành công việc liên quan đến tế tự vì ngày này quỷ thần không bình thường',
    'description': 'Ngày Dần kỵ tế tự, cúng bái',
    'avoidActivities': ['Tế tự', 'Cúng bái', 'Lễ nghi tôn giáo'],
  },
  'Mão': {
    'prohibition': 'Bất tế tự quỷ thần bất thường',
    'vietnamese': 'Không nên tế tự vì quỷ thần không bình thường',
    'description': 'Ngày Mão kỵ tế tự',
    'avoidActivities': ['Tế tự', 'Cúng bái'],
  },
  'Thìn': {
    'prohibition': 'Bất động thổ, tất kiến họa',
    'vietnamese': 'Không nên động thổ để tránh họa',
    'description': 'Ngày Thìn kỵ động thổ, xây dựng',
    'avoidActivities': ['Động thổ', 'Xây dựng', 'Đào đất'],
  },
  'Tỵ': {
    'prohibition': 'Bất tế tự quỷ thần bất thường',
    'vietnamese': 'Không nên tế tự vì quỷ thần không bình thường',
    'description': 'Ngày Tỵ kỵ tế tự',
    'avoidActivities': ['Tế tự', 'Cúng bái'],
  },
  'Ngọ': {
    'prohibition': 'Bất tu táo tất kiến hỏa ương',
    'vietnamese': 'Không nên sửa chữa bếp để tránh hỏa tai',
    'description': 'Ngày Ngọ kỵ sửa chữa bếp',
    'avoidActivities': ['Sửa chữa bếp', 'Xây dựng bếp'],
  },
  'Mùi': {
    'prohibition': 'Bất động thổ, tất kiến họa',
    'vietnamese': 'Không nên động thổ để tránh họa',
    'description': 'Ngày Mùi kỵ động thổ',
    'avoidActivities': ['Động thổ', 'Xây dựng'],
  },
  'Thân': {
    'prohibition': 'Bất tu kim, tất kiến họa',
    'vietnamese': 'Không nên sửa chữa đồ kim loại để tránh họa',
    'description': 'Ngày Thân kỵ sửa chữa kim loại',
    'avoidActivities': ['Sửa chữa kim loại', 'Rèn đúc'],
  },
  'Dậu': {
    'prohibition': 'Bất tu kim, tất kiến họa',
    'vietnamese': 'Không nên sửa chữa đồ kim loại để tránh họa',
    'description': 'Ngày Dậu kỵ sửa chữa kim loại',
    'avoidActivities': ['Sửa chữa kim loại', 'Rèn đúc'],
  },
  'Tuất': {
    'prohibition': 'Bất động thổ, tất kiến họa',
    'vietnamese': 'Không nên động thổ để tránh họa',
    'description': 'Ngày Tuất kỵ động thổ',
    'avoidActivities': ['Động thổ', 'Xây dựng'],
  },
  'Hợi': {
    'prohibition': 'Bất tu thủy, tất kiến họa',
    'vietnamese': 'Không nên sửa chữa đường nước để tránh họa',
    'description': 'Ngày Hợi kỵ sửa chữa đường nước',
    'avoidActivities': ['Sửa chữa đường nước', 'Đào giếng'],
  },
};

/// Các Ngày Kỵ - Days to Avoid
/// Based on traditional Vietnamese calendar knowledge
const List<Map<String, dynamic>> ngayKyData = [
  {
    'id': 'sat_chu_am',
    'name': 'Sát Chủ Âm',
    'vietnameseName': 'Sát Chủ Âm',
    'description': 'Ngày Sát Chủ Âm là ngày kỵ các việc về mai táng, tu sửa mộ phần',
    'avoidActivities': ['Mai táng', 'Tu sửa mộ phần', 'Cải táng', 'An táng'],
    'calculationRule': 'Based on specific Can Chi combinations',
  },
  // Add more ngày kỵ as needed
];

