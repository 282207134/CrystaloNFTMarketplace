import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key, this.activity = false});
  final bool activity;
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late int tab = widget.activity ? 1 : 0;
  bool expanded = false;
  String query = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const ArtImage(
                'collection_cover',
                height: 248,
                width: double.infinity,
                radius: 0,
              ),
              SafeArea(
                minimum: const EdgeInsets.only(top: 44),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      RoundAction(Icons.arrow_back, onTap: () => back(context)),
                      const Spacer(),
                      RoundAction(
                        Icons.favorite_border,
                        onTap: () {
                          AppScope.read(context).toggleFollow('MetaGlow XI');
                          message(context, 'Collection watchlist updated');
                        },
                      ),
                      const SizedBox(width: 12),
                      RoundAction(
                        Icons.share_outlined,
                        onTap: () => SharePlus.instance.share(
                          ShareParams(
                            text: 'Discover MetaGlow XI on Crystalo (demo)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 172, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 32),
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MetaGlow XI',
                            style: type(22, weight: FontWeight.w600),
                          ),
                          const SizedBox(width: 5),
                          const Verified(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Created By NFTFiber',
                        style: type(13, color: C.muted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '45K items · Created Dec, 2022 · 10% Creator fee',
                        style: type(11, color: C.muted),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'MetaGlow XI are a collection of 10,000 precious NFTs, focused on new modern trends ${expanded ? 'and bringing collectors and artists together through creative collaboration.' : 'collaboration…'}',
                        textAlign: TextAlign.center,
                        style: type(13, color: C.muted, height: 1.5),
                      ),
                      InkWell(
                        onTap: () => setState(() => expanded = !expanded),
                        child: Text(
                          expanded ? 'See less' : 'See more',
                          style: type(13, color: C.gold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Stats([
                        ('20K', 'total volume'),
                        ('35%', 'unique owner'),
                        ('0.87 ETH', 'floor price'),
                        ('0.85 ETH', 'current bid'),
                      ]),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(child: Avatar('avatar_metaglow', size: 104)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Segments(
                  const ['▦  Items', '⌁  Activity'],
                  selected: tab,
                  onChanged: (i) => setState(() => tab = i),
                ),
                const SizedBox(height: 16),
                if (tab == 0) ...[
                  TextField(
                    onChanged: (v) => setState(() => query = v.toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: 'Search items',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NftGrid(
                    metaglow
                        .where((n) => n.name.toLowerCase().contains(query))
                        .toList(),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: Text('Price History', style: type(16))),
                      const Chip(
                        label: Text(
                          'Last 90 Days',
                          style: TextStyle(color: C.gold, fontSize: 12),
                        ),
                        backgroundColor: C.card,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Stats([
                    ('\$145', '90 Day Avg. Price'),
                    ('10k', '90 Day Volume'),
                  ]),
                  const SizedBox(height: 24),
                  const SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CustomPaint(painter: PriceChartPainter()),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ArtImage(metaglow[i].image, width: 64, height: 64),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('MetaGlow XI', style: type(14)),
                                  Text(
                                    metaglow[i].name,
                                    style: type(12, color: C.muted),
                                  ),
                                  Text(
                                    '+ More',
                                    style: type(12, color: C.gold),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Sale', style: type(12, color: C.gold)),
                                Text(
                                  '${eth(metaglow[i].price)} ETH',
                                  style: type(14),
                                ),
                                Text(
                                  '${42 - i * 5} seconds ago',
                                  style: type(10, color: C.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PriceChartPainter extends CustomPainter {
  const PriceChartPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const values = [
      .06,
      .10,
      .18,
      .31,
      .42,
      .36,
      .27,
      .29,
      .43,
      .56,
      .60,
      .61,
      .70,
      .86,
    ];
    final line = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1),
          y = (1 - values[i]) * (size.height - 24);
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height - 24)
      ..lineTo(0, size.height - 24)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x66F8BB5A), Color(0x00F8BB5A)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = C.gold
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    const labels = ['Nov 5', 'Nov 25', 'Dec 9', 'Dec 27', 'Jan 5', 'Jan 25'];
    for (var i = 0; i < labels.length; i++) {
      final text = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: type(10, color: C.muted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        Offset(i * (size.width - 32) / (labels.length - 1), size.height - 14),
      );
    }
  }

  @override
  bool shouldRepaint(PriceChartPainter oldDelegate) => false;
}

class NftDetailPage extends StatefulWidget {
  const NftDetailPage({super.key, this.initialTab = 0, this.share = false});
  final int initialTab;
  final bool share;
  @override
  State<NftDetailPage> createState() => _NftDetailPageState();
}

class _NftDetailPageState extends State<NftDetailPage> {
  late int tab = widget.initialTab;
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context), nft = store.selectedNft;
    final page = Scaffold(
      body: SafeArea(
        bottom: false,
        minimum: const EdgeInsets.only(top: 44),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RoundAction(Icons.arrow_back, onTap: () => back(context)),
                  const Spacer(),
                  RoundAction(
                    store.favorites.contains(nft.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    key: const ValueKey('favorite'),
                    onTap: () => store.toggleFavorite(nft.id),
                    tooltip: 'Favorite',
                  ),
                  const SizedBox(width: 12),
                  RoundAction(
                    Icons.share_outlined,
                    onTap: () => go(context, 23),
                    tooltip: 'Share',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 380 / 276,
                child: ArtImage(nft.image, upload: nft.upload, radius: 24),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => go(context, 20),
                child: Row(
                  children: [
                    Text(
                      nft.collection,
                      style: type(20, color: C.gold, weight: FontWeight.w600),
                    ),
                    const SizedBox(width: 5),
                    const Verified(),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(nft.name, style: type(22, weight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(
                nft.description.isNotEmpty
                    ? nft.description
                    : '${nft.name} is a modern NFT based on community-focused project centered around collaboration${expanded ? ', bringing digital artists and collectors together to explore new forms of expression.' : '…'}',
                style: type(
                  14,
                  color: C.muted,
                  weight: FontWeight.w400,
                  height: 20 / 14,
                ),
                maxLines: expanded ? null : 2,
                overflow: expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
              InkWell(
                onTap: () => setState(() => expanded = !expanded),
                child: Text(
                  expanded ? 'See less' : 'See more',
                  style: type(14, color: C.gold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (i) {
                  final stats = [
                    (
                      '${store.favorites.contains(nft.id) ? 13 : 12}',
                      'Favorites',
                      Icons.favorite,
                    ),
                    ('1', 'Owners', Icons.people_outline),
                    ('1', 'Edition', Icons.grid_view),
                    ('4.5k', 'Visitors', Icons.visibility_outlined),
                  ];
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(stats[i].$3, size: 15, color: C.muted),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  stats[i].$1,
                                  style: type(14, color: C.muted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(stats[i].$2, style: type(11, color: C.muted)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _person('Created by', 'NFTFiber', nft.avatar),
                  ),
                  Expanded(
                    child: _person(
                      'Owned by',
                      store.owned.contains(nft.id) ? store.username : 'Sunley',
                      'avatar_sunley',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Segments(
                const ['DETAILS', 'BIDS', 'OWNERS', 'HISTORY'],
                selected: tab,
                onChanged: (i) => setState(() => tab = i),
                underline: true,
              ),
              const SizedBox(height: 10),
              if (tab == 0) ...[
                const KeyValue('Created at', '08/31/22 · 20:14:46'),
                const Divider(height: 1),
                const KeyValue(
                  'Contract Address',
                  '0x38689…3267',
                  color: C.gold,
                ),
                const Divider(height: 1),
                KeyValue('Token ID', nft.id),
                const Divider(height: 1),
                const KeyValue('Blockchain', 'Ethereum'),
                const Divider(height: 1),
                const KeyValue('Creator Earning', '10%'),
              ],
              if (tab == 1) ...[
                for (final t in store.transactions.where(
                  (t) => t['type'] == 'Bid' && t['name'] == nft.name,
                ))
                  _activity(
                    'Bid by @${store.username}',
                    'Just now',
                    '${eth((t['amount'] as num).toDouble())} ETH',
                    'avatar_john',
                  ),
                _activity(
                  'Bid by @mike',
                  'May 31, 2021 at 10:31am',
                  '0.86 ETH',
                  'avatar_john',
                ),
                _activity(
                  'Bid by @mike',
                  'May 31, 2021 at 10:31am',
                  '0.86 ETH',
                  'avatar_john',
                ),
              ],
              if (tab == 2)
                _activity(
                  'Owned by ${store.owned.contains(nft.id) ? store.username : 'Sunley'}',
                  '2 days ago',
                  '',
                  'avatar_sunley',
                ),
              if (tab == 3) ...[
                for (final t in store.transactions.where(
                  (t) => t['name'] == nft.name,
                ))
                  _activity(
                    '${t['type']} · ${t['amount']} ETH',
                    'Just now',
                    '',
                    'avatar_john',
                  ),
                _activity(
                  'Put on sale for ${eth(nft.price)} ETH',
                  '16 days ago',
                  '',
                  'avatar_sunley',
                ),
                _activity(
                  'Bought at 0.85 ETH',
                  '16 days ago',
                  '',
                  'avatar_sunley',
                ),
                _activity(
                  'The NFT was minted',
                  '24 days ago',
                  '',
                  'avatar_metaglow',
                ),
              ],
              const SizedBox(height: 24),
              const SectionTitle('More from this collection'),
              const NftGrid(metaglow),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BidFooter(nft: nft),
    );
    if (!widget.share) return page;
    return Stack(
      children: [
        page,
        Container(color: Colors.black.withValues(alpha: .72)),
        Align(
          alignment: Alignment.bottomCenter,
          child: _SharePanel(nft: nft),
        ),
      ],
    );
  }

  Widget _person(String label, String name, String image) => InkWell(
    onTap: () => go(context, 20),
    child: Row(
      children: [
        Avatar(image, size: 32),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: type(11, color: C.muted)),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name.length > 16 ? '${name.substring(0, 14)}…' : name,
                      style: type(14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Verified(size: 12),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _activity(String title, String date, String amount, String image) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Avatar(image, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: type(13)),
                  const SizedBox(height: 4),
                  Text(date, style: type(10, color: C.muted)),
                ],
              ),
            ),
            Text(amount, style: type(12, color: C.gold)),
          ],
        ),
      );
}

class _BidFooter extends StatelessWidget {
  const _BidFooter({required this.nft});
  final Nft nft;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
    ),
    padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Bid', style: type(16)),
                      const SizedBox(height: 3),
                      Text(
                        '${eth(AppScope.of(context).highestBid)} ETH',
                        style: type(22, color: C.gold, weight: FontWeight.w600),
                      ),
                      Text('\$1,030.10', style: type(14)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auction ends in', style: type(16)),
                    const SizedBox(height: 3),
                    Text('14  ·  23  ·  16', style: type(22, color: C.gold)),
                    Text('Hrs    Mins    Secs', style: type(13, color: C.gold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GoldButton(
                  AppScope.of(context).owned.contains(nft.id)
                      ? 'Owned'
                      : 'Purchase',
                  key: const ValueKey('purchase'),
                  outline: true,
                  onTap: AppScope.of(context).owned.contains(nft.id)
                      ? null
                      : () => go(context, 31),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GoldButton(
                  'Place a bid',
                  key: const ValueKey('place-bid'),
                  onTap: () => go(context, 28),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SharePanel extends StatelessWidget {
  const _SharePanel({required this.nft});
  final Nft nft;
  @override
  Widget build(BuildContext context) {
    const names = [
      'Facebook',
      'WhatsApp',
      'Twitter',
      'Instagram',
      'TikTok',
      'Snapchat',
      'Telegram',
      'Discord',
    ];
    const colors = [
      Color(0xFF1877F2),
      Color(0xFF25D366),
      Color(0xFF1DA1F2),
      Colors.white,
      Colors.black,
      Color(0xFFFFFC00),
      Color(0xFF229ED9),
      Color(0xFF5865F2),
    ];
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: C.gold,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 40),
                  const Spacer(),
                  const Icon(
                    Icons.share_outlined,
                    color: C.background,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Share', style: type(20, color: C.background)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => back(context),
                    icon: const Icon(Icons.close, color: C.background),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 20,
                      runSpacing: 24,
                      children: List.generate(
                        8,
                        (i) => SizedBox(
                          width: 62,
                          child: InkWell(
                            onTap: () => SharePlus.instance.share(
                              ShareParams(
                                text:
                                    '${nft.name} · ${eth(nft.price)} ETH\nCrystalo NFT marketplace demo',
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 23,
                                  backgroundColor: colors[i],
                                  child: Text(
                                    [
                                      'f',
                                      '◉',
                                      '𝕏',
                                      '◎',
                                      '♪',
                                      '♧',
                                      '➤',
                                      '☷',
                                    ][i],
                                    style: type(
                                      28,
                                      color: i == 3 || i == 5
                                          ? C.background
                                          : Colors.white,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(names[i], style: type(10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                'Crystalo · ${nft.name} · ${eth(nft.price)} ETH',
                          ),
                        );
                        message(context, 'NFT details copied');
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy NFT details'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TradePage extends StatefulWidget {
  const TradePage({super.key, this.purchase = false, this.success = 0});
  final bool purchase;
  final int success;
  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  late final amount = TextEditingController(
    text: widget.purchase
        ? eth(AppScope.read(context).selectedNft.price)
        : eth(AppScope.read(context).highestBid + .01),
  );
  String? error;
  bool submitting = false;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final store = AppScope.read(context);
    setState(() => submitting = true);
    try {
      if (widget.purchase) {
        await store.purchase();
      } else {
        await store.bid(double.tryParse(amount.text) ?? 0);
      }
      if (mounted) go(context, widget.purchase ? 33 : 30, replace: true);
    } on FormatException catch (e) {
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context), nft = store.selectedNft;
    final page = AppPage(
      title: widget.purchase ? 'Purchase' : 'Place a bid',
      bottom: GoldButton(
        submitting
            ? 'Processing…'
            : widget.purchase
            ? 'Complete Purchase'
            : 'Place a bid',
        key: const ValueKey('confirm-trade'),
        onTap: submitting ? null : _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 380 / 276,
            child: ArtImage(nft.image, upload: nft.upload, radius: 24),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nft.collection,
                            style: type(16, color: C.gold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Verified(size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(nft.name, style: type(20, weight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Owned by Sunley', style: type(11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.purchase ? 'Floor Price' : 'Current Bid',
                    style: type(12),
                  ),
                  Text(
                    '${widget.purchase ? eth(nft.price) : eth(store.highestBid)} ETH',
                    style: type(20, color: C.gold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.purchase ? '\$1,214.38' : '\$1,030.10',
                    style: type(11),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          Text('Connect Wallet', style: type(14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/metamask.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(store.walletProvider, style: type(16))),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: C.gold,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Connected',
                    style: type(12, color: C.background),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.purchase ? 'Amount' : 'Bid Amount',
                  style: type(14),
                ),
              ),
              Text(
                'Your Balance: ${eth(store.balance)} ETH',
                style: type(10, color: C.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('trade-amount'),
            controller: amount,
            readOnly: widget.purchase,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: Text('◆ ETH ›', style: type(14)),
              ),
              errorText: error,
            ),
          ),
          const SizedBox(height: 12),
          const KeyValue('Service fee', '0 ETH'),
          const Divider(height: 1),
          KeyValue('Total Amount', '${amount.text} ETH'),
          const SizedBox(height: 10),
          Text(
            'Demo transaction · no blockchain submission',
            style: type(11, color: C.dim),
          ),
        ],
      ),
    );
    if (widget.success == 0) return page;
    return SuccessOverlay(
      background: page,
      nft: nft,
      compact: widget.success == 1,
      title: widget.success == 1
          ? (widget.purchase
                ? 'Make a purchase successfully'
                : 'Placed a bid successfully')
          : 'Congratulations',
      subtitle: widget.purchase
          ? 'You have successfully purchased NFT.'
          : 'You have successfully placed a bid for NFT.',
      button: widget.purchase ? 'View NFT' : 'View Bid',
      onPrimary: () => go(context, widget.purchase ? 22 : 25, replace: true),
    );
  }
}

class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({
    super.key,
    required this.background,
    required this.nft,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onPrimary,
    this.compact = false,
  });
  final Widget background;
  final Nft nft;
  final String title, subtitle, button;
  final VoidCallback onPrimary;
  final bool compact;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      background,
      Container(color: Colors.black.withValues(alpha: .80)),
      Align(
        alignment: compact ? Alignment.bottomCenter : Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.fromLTRB(
              compact ? 0 : 24,
              48,
              compact ? 0 : 24,
              compact ? 0 : 48,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(compact ? 32 : 16),
            ),
            child: SafeArea(
              top: false,
              bottom: compact,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (compact) ...[
                      ArtImage(
                        nft.image,
                        upload: nft.upload,
                        width: 132,
                        height: 132,
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      title,
                      style: type(compact ? 20 : 22, weight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: type(13, color: C.muted, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 24),
                      AspectRatio(
                        aspectRatio: 1.25,
                        child: ArtImage(
                          nft.image,
                          upload: nft.upload,
                          radius: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(nft.name, style: type(18)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final icon in [
                            Icons.public,
                            Icons.facebook,
                            Icons.alternate_email,
                            Icons.camera_alt_outlined,
                            Icons.forum_outlined,
                          ])
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                              ),
                              child: Icon(icon, size: 17, color: C.gold),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    GoldButton(button, onTap: onPrimary),
                    const SizedBox(height: 12),
                    GoldButton(
                      'Back',
                      secondary: true,
                      onTap: () => go(context, 22, replace: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
