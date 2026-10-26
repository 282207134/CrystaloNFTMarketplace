import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/app_store.dart';
import 'features/auth/auth_pages.dart';
import 'features/market/market_pages.dart';
import 'features/nft/nft_pages.dart';
import 'features/profile/profile_pages.dart';
import 'features/settings/settings_pages.dart';
import 'features/wallet/wallet_pages.dart';

class CrystaloApp extends StatelessWidget {
  const CrystaloApp({
    super.key,
    required this.store,
    this.initialScreen = 1,
    this.autoAdvance = true,
    this.navigatorKey,
  });
  final AppStore store;
  final int initialScreen;
  final bool autoAdvance;
  final GlobalKey<NavigatorState>? navigatorKey;
  @override
  Widget build(BuildContext context) => AppScope(
    store: store,
    child: MaterialApp(
      title: 'Crystalo',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      navigatorKey: navigatorKey,
      initialRoute: '/screen/$initialScreen',
      onGenerateInitialRoutes: (name) => [_route(name)],
      onGenerateRoute: (settings) => _route(settings.name ?? '/screen/5'),
      builder: (context, child) => ColoredBox(
        color: const Color(0xFF100F0E),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
    ),
  );
  Route<dynamic> _route(String name) => MaterialPageRoute(
    settings: RouteSettings(name: name),
    builder: (context) => name == '/gallery'
        ? const ScreenGalleryPage()
        : KeyedSubtree(
            key: ValueKey(name),
            child: _screen(int.tryParse(name.split('/').last) ?? 5),
          ),
  );
  Widget _screen(int id) => switch (id) {
    1 => SplashPage(autoAdvance: autoAdvance),
    2 => const OnboardingPage(),
    3 => const SignInPage(),
    4 => const WalletConnectPage(),
    5 || 6 => const HomePage(),
    7 => const NotificationPage(),
    8 => const CategoriesPage(),
    9 => const SellersPage(),
    10 => const SellersPage(initialTab: 1),
    11 => const ArtCollectionPage(),
    12 => const SearchPage(),
    13 => const SearchPage(results: true),
    14 || 15 => const FilterPage(),
    16 || 17 => const FilterPage(sheet: true),
    18 => const RankingPage(),
    19 => const RankingPage(expanded: true),
    20 => const CollectionPage(),
    21 => const CollectionPage(activity: true),
    22 || 24 => const NftDetailPage(),
    23 => const NftDetailPage(share: true),
    25 => const NftDetailPage(initialTab: 1),
    26 => const NftDetailPage(initialTab: 2),
    27 => const NftDetailPage(initialTab: 3),
    28 => const TradePage(),
    29 => const TradePage(success: 1),
    30 => const TradePage(success: 2),
    31 => const TradePage(purchase: true),
    32 => const TradePage(purchase: true, success: 1),
    33 => const TradePage(purchase: true, success: 2),
    34 => const ProfilePage(),
    35 => const ProfilePage(owned: true),
    36 => const EditProfilePage(),
    37 => const CreateNftPage(),
    38 => const CreateNftPage(success: true),
    39 => const ListingPage(),
    40 => const ListingPage(auction: true),
    41 => const CreateNftPage(success: true, listed: true),
    42 => const MorePage(),
    43 => const WalletPage(),
    44 => const SendEthPage(),
    45 => const ReceiveEthPage(),
    46 => const BuyEthPage(),
    47 => const SwapEthPage(),
    48 => const MorePage(settings: true),
    49 => const NotificationSettingsPage(),
    50 => const HelpCenterPage(),
    _ => const HomePage(),
  };
}
