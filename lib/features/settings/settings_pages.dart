import 'package:flutter/material.dart';

import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key, this.settings = false});
  final bool settings;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppPage(
      title: settings ? 'Setting' : 'More',
      navIndex: 3,
      child: Column(
        children: [
          if (!settings) ...[
            _row(
              context,
              'My Wallet',
              Icons.account_balance_wallet_outlined,
              const Color(0xFFF8CE89),
              () => go(context, 43),
            ),
            _row(
              context,
              'My Collection',
              Icons.grid_view,
              const Color(0xFFF9A7E5),
              () => go(context, 34),
            ),
            _row(
              context,
              'Favorites',
              Icons.favorite_border,
              const Color(0xFFE1D4F8),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemsPage(
                    title: 'Favorites',
                    items: store.allNfts
                        .where((n) => store.favorites.contains(n.id))
                        .toList(),
                  ),
                ),
              ),
            ),
            _row(
              context,
              'Watchlist',
              Icons.visibility_outlined,
              const Color(0xFFF6E9D7),
              () => _watchlist(context),
            ),
            _row(
              context,
              'Setting',
              Icons.settings_outlined,
              const Color(0xFFF9AFBD),
              () => go(context, 48),
            ),
            _row(
              context,
              'Language',
              Icons.translate,
              const Color(0xFFD8F4DE),
              () => message(
                context,
                '${store.language} · original UI kit language',
              ),
              value: store.language,
            ),
          ] else ...[
            _row(
              context,
              'Featured Items',
              Icons.favorite_border,
              const Color(0xFFF9AFBD),
              () => go(context, 20),
            ),
            _row(
              context,
              'Notifications',
              Icons.notifications_none,
              const Color(0xFF22C55E),
              () => go(context, 49),
            ),
            _row(
              context,
              'Offers',
              Icons.sell_outlined,
              const Color(0xFFF8CE89),
              () {},
              trailing: Switch(
                value: store.offers,
                onChanged: (v) {
                  store.offers = v;
                  store.save();
                },
              ),
            ),
            _row(
              context,
              'Help Center',
              Icons.help_outline,
              const Color(0xFFA9D7F3),
              () => go(context, 50),
            ),
            _row(
              context,
              'Earnings',
              Icons.attach_money,
              const Color(0xFFE0F2FE),
              () => _earnings(context),
            ),
            _row(
              context,
              'About',
              Icons.info_outline,
              const Color(0xFF22D3EE),
              () => _about(context),
            ),
          ],
        ],
      ),
    );
  }

  void _watchlist(BuildContext context) {
    final store = AppScope.read(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Watchlist', style: type(22)),
            if (store.following.isEmpty)
              const EmptyState(
                'Your watchlist is empty',
                'Follow creators to keep them here.',
              )
            else
              ...store.following.map(
                (s) => ListTile(
                  title: Text(s),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => go(ctx, 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback tap, {
    String? value,
    Widget? trailing,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        onTap: tap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: C.background, size: 26),
        ),
        title: Text(label, style: type(16)),
        trailing:
            trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null) Text(value, style: type(12, color: C.gold)),
                const Icon(Icons.chevron_right, size: 22),
              ],
            ),
      ),
    ),
  );
  void _earnings(BuildContext context) {
    final listings = AppScope.read(context).transactions
        .where((t) => t['type'].toString().contains('listing'))
        .length;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Earnings', style: type(24)),
            const SizedBox(height: 24),
            Text('0 ETH', style: type(36, color: C.gold)),
            const SizedBox(height: 12),
            Text(
              '$listings local listings · no completed sales',
              style: type(14, color: C.muted),
            ),
            const SizedBox(height: 16),
            const Text('Demo transactions do not generate real earnings.'),
          ],
        ),
      ),
    );
  }

  void _about(BuildContext context) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandMark(size: 64),
          const SizedBox(height: 16),
          Text('Crystalo', style: type(28, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('NFT marketplace · v1.0.0', style: type(14, color: C.muted)),
          const SizedBox(height: 16),
          const Text(
            'A Flutter interpretation of the 50-screen Pixso UI kit. All wallet and trading operations use local demonstration data.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GoldButton(
            'Browse all 50 screens',
            onTap: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/gallery');
            },
          ),
          TextButton(
            onPressed: () =>
                showLicensePage(context: context, applicationName: 'Crystalo'),
            child: const Text('Open-source licenses'),
          ),
        ],
      ),
    ),
  );
}

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key, required this.title, required this.items});
  final String title;
  final List<Nft> items;
  @override
  Widget build(BuildContext context) =>
      AppPage(title: title, child: NftGrid(items));
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppPage(
      title: 'Notification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New', style: type(14, color: C.muted)),
          const SizedBox(height: 16),
          _row(
            'avatar_john',
            'Maya followed you',
            '11:25 AM',
            SizedBox(
              width: 86,
              child: GoldButton(
                store.following.contains('Maya') ? 'Following' : 'Follow',
                height: 36,
                onTap: () => store.toggleFollow('Maya'),
              ),
            ),
          ),
          _row(
            'category_sports',
            'Robert Jones likes your\nLeafier #133 NFT',
            '11 Nov 2022, 14:24 AM',
            const ArtImage('leaf_red', width: 48, height: 48),
          ),
          const Divider(height: 32),
          Text('This week', style: type(14, color: C.muted)),
          const SizedBox(height: 16),
          _row(
            'avatar_torakus',
            'New bid on Leafier #124\n0.22 ETH',
            '12 Nov 2022, 13:24 PM',
            const ArtImage('leaf_blue', width: 48, height: 48),
          ),
          _row(
            'wallet_avatar',
            'New bid added to\nmarketplace',
            '12 Nov 2022, 13:24 PM',
            SizedBox(
              width: 100,
              child: GoldButton(
                'Place a bid',
                outline: true,
                height: 36,
                onTap: () => go(context, 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String image, String title, String date, Widget action) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ArtImage(image, width: 48, height: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: type(13)),
                  const SizedBox(height: 5),
                  Text(date, style: type(10, color: C.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            action,
          ],
        ),
      );
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppPage(
      title: 'Notification',
      child: Column(
        children: List.generate(
          6,
          (i) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              [
                'Bid Activity',
                'Price Change',
                'Auction Expiration',
                'Outbid',
                'Owned Item Updates',
                'Successful Purchase',
              ][i],
              style: type(16),
            ),
            value: store.notifications[i],
            onChanged: (v) {
              store.notifications[i] = v;
              store.save();
            },
          ),
        ),
      ),
    );
  }
}

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    const titles = [
      'Getting Started',
      'Buy',
      'Sell',
      'Create',
      'FAQs',
      'User Safety',
      'Developers',
      'Contact',
    ];
    const icons = [
      Icons.keyboard_command_key,
      Icons.shopping_cart_outlined,
      Icons.shopping_bag_outlined,
      Icons.edit_outlined,
      Icons.info_outline,
      Icons.shield_outlined,
      Icons.code,
      Icons.phone_outlined,
    ];
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF7C3AED),
      Color(0xFFEC4899),
      C.gold,
      Color(0xFFFCD18A),
      Color(0xFF22C55E),
      Color(0xFF1677F8),
      Color(0xFFE5AC4E),
    ];
    const content = [
      'Start with Explore to discover categories, creators and collections. Open an NFT to view its details, bids, owners and history. You can connect a demo wallet from the sign-in flow.',
      'Open an NFT and choose Purchase. Check the price and demo balance, then complete the purchase. Your NFT appears in Profile → Owned and My Wallet → NFT.',
      'Create an item from the + button on your profile, then choose List Item. Set a fixed price or a minimum auction bid. The listing is saved in local activity.',
      'Upload an image or use the sample artwork. Enter a title and description, choose a collection and create the NFT. This demo saves the image and metadata on your device.',
      'Are transactions real? No. All prices, balances, listings and transactions are demonstration data. Are changes saved? Favorites, profiles, settings and demo activity persist on this device.',
      'Never share a seed phrase or private key. This demo never requests either. Do not send real funds to its illustrative wallet address. Native sharing only shares the text you select.',
      'The app uses Flutter with shared presentation components, feature pages and a local AppStore. See docs/项目说明.md for the architecture, page mapping and production integration boundaries.',
      'This reference UI kit does not provide a support endpoint. For this implementation, report issues with the screen number and reproduction steps to the project maintainer. No message is sent from this page.',
    ];
    return AppPage(
      title: 'Help Center',
      child: LayoutBuilder(
        builder: (context, c) => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            8,
            (i) => SizedBox(
              width: (c.maxWidth - 16) / 2,
              height: 174,
              child: Material(
                color: colors[i],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (ctx) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titles[i],
                              style: type(24, weight: FontWeight.w600),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              content[i],
                              style: type(16, color: C.muted, height: 1.7),
                            ),
                            const SizedBox(height: 20),
                            GoldButton(
                              'Got it',
                              onTap: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icons[i], size: 28, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(titles[i], style: type(14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScreenGalleryPage extends StatelessWidget {
  const ScreenGalleryPage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'All 50 design screens',
    child: Column(
      children: List.generate(
        screenNames.length,
        (i) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: C.card,
            child: Text('${i + 1}', style: type(14, color: C.gold)),
          ),
          title: Text(screenNames[i], style: type(14)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(context, i + 1),
        ),
      ),
    ),
  );
}
