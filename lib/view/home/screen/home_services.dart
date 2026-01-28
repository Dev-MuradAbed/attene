import '../../../general_index.dart';
import 'home_product.dart';

class HomeServices extends StatelessWidget {
  const HomeServices({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ بدل ما تكون شاشة مستقلة (وتخفي BottomNav)
    // نخليها تفتح نفس HomeProduct لكن على تبويب الخدمات
    return const HomeProduct(initialTab: 1);
  }
}
