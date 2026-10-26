import 'package:flutter/material.dart';

import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    navIndex: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            InkWell(
              onTap: () => go(context, 34),
              child: const Avatar('avatar_john'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hi, ${AppScope.of(context).username == 'Leafier Skulls' ? 'John' : AppScope.of(context).username.split(' ').first}',
                style: type(16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => go(context, 43),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                decoration: BoxDecoration(
                  color: C.raised,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.token, color: C.gold, size: 25),
                    const SizedBox(width: 6),
                    Text(
                      AppScope.of(context).balance
                          .toStringAsFixed(0)
                          .replaceFirstMapped(
                            RegExp(r'^(\d+)(\d{3})$'),
                            (m) => '${m[1]},${m[2]}',
                          ),
                      style: type(16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            RoundAction(
              Icons.notifications_none_rounded,
              onTap: () => go(context, 7),
              tooltip: 'Notifications',
            ),
          ],
        ),
        const SizedBox(height: 24),
        SearchBox(onTap: () => go(context, 12)),
        const SizedBox(height: 24),
        SectionTitle('Categories', onTap: () => go(context, 8)),
        SizedBox(
          height: 135,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, i) => const SizedBox(width: 16),
            itemBuilder: (context, i) =>
                SizedBox(width: 116, child: CategoryCard(i)),
          ),
        ),
        const SizedBox(height: 24),
        SectionTitle('Top sellers and creators', onTap: () => go(context, 9)),
        Row(
          children: [
            Expanded(
              child: _SellerPill(
                'KNS_Khass',
                'seller_khass',
                '22.5 ETH',
                () => go(context, 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SellerPill(
                'Moazily',
                'avatar_moazily',
                '18.5 ETH',
                () => go(context, 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionTitle('Trending NFTs', onTap: () => go(context, 20)),
        const NftGrid(trending),
        const SizedBox(height: 32),
        SectionTitle('Top Collections', onTap: () => go(context, 20)),
        const Row(
          children: [
            Expanded(
              child: CollectionCard(
                'MetaGlow XI',
                'collection_metaglow',
                'avatar_metaglow',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CollectionCard(
                'CryptoGuard',
                'collection_crypto',
                'wallet_avatar',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SellerPill extends StatelessWidget {
  const _SellerPill(this.name, this.image, this.amount, this.onTap);
  final String name, image, amount;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Avatar(image),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: type(14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(amount, style: type(12, color: C.gold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CategoryCard extends StatelessWidget {
  const CategoryCard(this.index, {super.key});
  final int index;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      AppScope.read(context).selectedCategory = categories[index];
      go(context, 11);
    },
    child: Container(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: ArtImage(
              categoryImages[index],
              width: double.infinity,
              radius: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(categories[index], style: type(12)),
        ],
      ),
    ),
  );
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Categories',
    child: LayoutBuilder(
      builder: (context, c) => Wrap(
        spacing: 16,
        runSpacing: 16,
        children: List.generate(
          6,
          (i) => SizedBox(
            width: (c.maxWidth - 16) / 2,
            height: 190,
            child: CategoryCard(i),
          ),
        ),
      ),
    ),
  );
}

class CollectionCard extends StatelessWidget {
  const CollectionCard(this.title, this.image, this.avatar, {super.key});
  final String title, image, avatar;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => go(context, 20),
    child: Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ArtImage(image, height: 122, width: double.infinity, radius: 0),
              Positioned(
                left: 11,
                bottom: -15,
                child: Avatar(avatar, size: 56),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 25, 8, 16),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: type(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Verified(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SellersPage extends StatefulWidget {
  const SellersPage({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<SellersPage> createState() => _SellersPageState();
}

class _SellersPageState extends State<SellersPage> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Top Sellers & Creators',
    child: Column(
      children: [
        Segments(
          const ['Seller', 'Creator'],
          selected: tab,
          onChanged: (i) => setState(() => tab = i),
        ),
        const SizedBox(height: 24),
        if (tab == 0)
          ...List.generate(sellers.length, (i) {
            final s = sellers[i];
            final prefixes = [
              ['seller_art_1', 'seller_art_2', 'seller_art_3', 'seller_art_4'],
              ['face_hood', 'seller_face_1', 'seller_face_2', 'face_android'],
              [
                'seller_object_1',
                'seller_object_2',
                'seller_object_3',
                'seller_object_4',
              ],
              [
                'seller_space_1',
                'seller_space_2',
                'seller_space_3',
                'seller_space_4',
              ],
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => go(context, 20),
                    child: Row(
                      children: [
                        Avatar(s.image),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(s.name, style: type(16)),
                                const SizedBox(width: 4),
                                const Verified(),
                              ],
                            ),
                            Text(s.amount, style: type(14, color: C.gold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(
                      4,
                      (j) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: j == 3 ? 0 : 12),
                          child: InkWell(
                            onTap: () => go(context, 20),
                            child: ArtImage(prefixes[i][j], height: 84),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        if (tab == 1)
          ...creators.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => go(context, 20),
                    child: ArtImage(
                      c.cover,
                      height: 94,
                      width: double.infinity,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(16, -28),
                    child: Avatar(c.image, size: 56),
                  ),
                  Transform.translate(
                    offset: const Offset(16, -18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: type(18)),
                        Text('0x40c56…b24a', style: type(12, color: C.gold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 34,
                              child: GoldButton(
                                AppScope.of(context).following.contains(c.name)
                                    ? 'Following'
                                    : 'Follow',
                                secondary: true,
                                height: 34,
                                onTap: () =>
                                    AppScope.read(context).toggleFollow(c.name),
                              ),
                            ),
                            const SizedBox(width: 8),
                            RoundAction(
                              Icons.share_outlined,
                              size: 32,
                              onTap: () =>
                                  message(context, 'Creator: ${c.name}'),
                            ),
                            const SizedBox(width: 8),
                            RoundAction(
                              Icons.more_horiz,
                              size: 32,
                              onTap: () => go(context, 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class ArtCollectionPage extends StatefulWidget {
  const ArtCollectionPage({super.key});
  @override
  State<ArtCollectionPage> createState() => _ArtCollectionPageState();
}

class _ArtCollectionPageState extends State<ArtCollectionPage> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const ArtImage(
                'art_cover',
                height: 348,
                width: double.infinity,
                radius: 0,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundAction(Icons.arrow_back, onTap: () => back(context)),
                      RoundAction(
                        Icons.share_outlined,
                        onTap: () => go(context, 23),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 24,
                bottom: -52,
                child: Avatar('art_avatar', size: 104),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppScope.of(context).selectedCategory,
                  style: type(24, weight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  expanded
                      ? 'An online community of makers, developers, and traders is pushing the art world into new territory. Discover original digital artwork and meet the creators behind each collection.'
                      : 'An online community of makers, developers, and traders is pushing the art world into new territory…',
                  style: type(14, color: C.muted, height: 1.5),
                ),
                InkWell(
                  onTap: () => setState(() => expanded = !expanded),
                  child: Text(
                    expanded ? 'See less' : 'See more',
                    style: type(14, color: C.gold),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Trending Art Collections'),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(
                    8,
                    (i) => SizedBox(
                      width:
                          (MediaQuery.sizeOf(context).width.clamp(0, 520) -
                              64) /
                          2,
                      child: CollectionCard(
                        'CryptoGuard',
                        i % 2 == 0 ? 'art_collection_1' : 'art_collection_2',
                        'art_thumb_${i % 6 + 1}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GoldButton('See All Art NFTs', onTap: () => go(context, 20)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.results = false});
  final bool results;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final controller = TextEditingController(
    text: widget.results ? 'Crypto' : '',
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim().toLowerCase();
    final matches = AppScope.of(context).filter
        .apply(AppScope.read(context).allNfts)
        .where(
          (n) =>
              query == 'crypto' ||
              query.isEmpty ||
              '${n.name} ${n.collection}'.toLowerCase().contains(query),
        )
        .toList();
    return AppPage(
      scroll: false,
      child: Column(
        children: [
          const SizedBox(height: 20),
          SearchBox(
            controller: controller,
            onChanged: (_) => setState(() {}),
            hint: 'Search by collection, item or user',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: query.isEmpty
                ? Center(
                    child: Text(
                      'Search by collection, item or user',
                      style: type(13, color: C.muted),
                    ),
                  )
                : ListView(
                    children: [
                      if (query == 'crypto' || 'metaglow'.contains(query)) ...[
                        Text('Collections', style: type(14, color: C.muted)),
                        const SizedBox(height: 12),
                        for (final (name, image) in [
                          ('CryptoPunky Official', 'face_neon'),
                          ('CryptoHoror Official', 'face_detective'),
                          ('CryptoGuard Official', 'face_mask'),
                        ])
                          _resultRow(name, image, () => go(context, 20)),
                        const Divider(height: 32),
                      ],
                      Text('NFTs', style: type(14, color: C.muted)),
                      const SizedBox(height: 12),
                      if (matches.isEmpty)
                        const EmptyState(
                          'No results',
                          'Try a different name or clear your filters.',
                        ),
                      for (final n in matches)
                        _resultRow(n.name, n.image, () {
                          AppScope.read(context).selectedNft = n;
                          go(context, 22);
                        }),
                      const Divider(height: 32),
                      Text('Users', style: type(14, color: C.muted)),
                      for (final c in creators.where(
                        (c) =>
                            query == 'crypto' ||
                            c.name.toLowerCase().contains(query),
                      ))
                        _resultRow(c.name, c.image, () => go(context, 20)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String name, String image, VoidCallback onTap) => ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
    leading: ArtImage(image, width: 44, height: 44),
    title: Row(
      children: [
        Flexible(child: Text(name, style: type(14))),
        const SizedBox(width: 5),
        const Verified(size: 14),
      ],
    ),
    onTap: onTap,
  );
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key, this.sheet = false});
  final bool sheet;
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late final MarketFilter filter = MarketFilter()
    ..sort = AppScope.read(context).filter.sort
    ..status = AppScope.read(context).filter.status
    ..category = AppScope.read(context).filter.category
    ..range = AppScope.read(context).filter.range
    ..chain = AppScope.read(context).filter.chain;
  void _apply() {
    final target = AppScope.read(context).filter;
    target.sort = filter.sort;
    target.status = filter.status;
    target.category = filter.category;
    target.range = filter.range;
    target.chain = filter.chain;
    message(context, 'Filters applied');
    go(context, 13, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel(
          'Sort By',
          Column(
            children:
                [
                      'Recently Created',
                      'Most Viewed',
                      'New',
                      'Low to High',
                      'High to Low',
                    ]
                    .map(
                      (s) => InkWell(
                        onTap: () => setState(() => filter.sort = s),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                filter.sort == s
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: C.gold,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(s, style: type(13)),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        _panel(
          'Status',
          _chips(
            ['Buy Now', 'On Auction', 'New', 'Offer Available'],
            filter.status,
            (s) => filter.status = s,
          ),
        ),
        _panel(
          'Price',
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${eth(filter.range.start)} ETH',
                    style: type(12, color: C.gold),
                  ),
                  Text(
                    '${eth(filter.range.end)} ETH',
                    style: type(12, color: C.gold),
                  ),
                ],
              ),
              RangeSlider(
                values: filter.range,
                min: .01,
                max: 10,
                divisions: 100,
                labels: RangeLabels(
                  eth(filter.range.start),
                  eth(filter.range.end),
                ),
                onChanged: (v) => setState(() => filter.range = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0.01 ETH', style: type(11)),
                  Text('10 ETH', style: type(11)),
                ],
              ),
            ],
          ),
        ),
        _panel(
          'Category',
          _chips(
            ['All', ...categories],
            filter.category,
            (s) => filter.category = s,
          ),
        ),
        _panel(
          'Blockchain',
          DropdownButtonFormField<String>(
            initialValue: 'All Chains',
            items: const [
              DropdownMenuItem(value: 'All Chains', child: Text('All Chains')),
              DropdownMenuItem(value: 'Ethereum', child: Text('Ethereum')),
            ],
            onChanged: (v) => filter.chain = v!,
          ),
        ),
      ],
    );
    final actions = Row(
      children: [
        Expanded(
          child: GoldButton(
            'Clear',
            secondary: true,
            onTap: () => setState(filter.clear),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GoldButton(
            'Apply',
            key: const ValueKey('apply-filter'),
            onTap: _apply,
          ),
        ),
      ],
    );
    if (!widget.sheet) {
      return AppPage(title: 'Filter', bottom: actions, child: body);
    }
    return Scaffold(
      body: Stack(
        children: [
          const HomePage(),
          Container(color: Colors.black.withValues(alpha: .72)),
          DraggableScrollableSheet(
            initialChildSize: .91,
            minChildSize: .5,
            maxChildSize: .97,
            builder: (context, controller) => Container(
              decoration: const BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: C.dim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text('Filter', style: type(20))),
                        RoundAction(
                          Icons.close,
                          onTap: () => back(context),
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [body],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.all(24),
                    child: actions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(String title, Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: C.background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: type(14)),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
  Widget _chips(
    List<String> items,
    String selected,
    ValueChanged<String> onTap,
  ) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items
        .map(
          (s) => ChoiceChip(
            label: Text(s),
            selected: s == selected,
            onSelected: (_) => setState(() => onTap(s)),
            showCheckmark: false,
            selectedColor: C.gold,
            backgroundColor: C.raised,
            side: BorderSide.none,
            labelStyle: type(
              12,
              color: s == selected ? C.background : Colors.white,
            ),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          ),
        )
        .toList(),
  );
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key, this.expanded = false});
  final bool expanded;
  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int tab = 0;
  late int expanded = widget.expanded ? 0 : -1;
  @override
  Widget build(BuildContext context) => AppPage(
    navIndex: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('NFT Ranking', style: type(22, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Explore top NFT ranking list of collections on\nCRYSTALO.',
          style: type(16, color: C.muted, height: 1.5),
        ),
        const SizedBox(height: 10),
        Segments(
          const ['ALL TIME', '1 DAY', '7 DAYS', '30 DAYS'],
          selected: tab,
          onChanged: (i) => setState(() => tab = i),
          underline: true,
        ),
        const SizedBox(height: 16),
        ...List.generate(ranking.length, (i) {
          final r = ranking[(i + tab) % ranking.length];
          final open = i == expanded;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: open ? C.gold : C.card,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(open ? 6 : 0),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => expanded = open ? -1 : i),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(open ? 14 : 20),
                    ),
                    child: Row(
                      children: [
                        Text('${i + 1}', style: type(16)),
                        const SizedBox(width: 10),
                        Avatar(r.image, size: 52),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      r.name,
                                      style: type(16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Verified(),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                open ? '− Less' : '+ More',
                                style: type(13, color: C.gold),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${r.amount} ETH',
                              style: type(14, color: C.gold),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              r.change,
                              style: type(
                                14,
                                color: r.change.startsWith('-')
                                    ? C.red
                                    : C.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (open)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 40,
                    ),
                    child: DefaultTextStyle(
                      style: type(12, color: C.background),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('Floor Price'),
                                SizedBox(height: 6),
                                Text('0.109 ETH'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text('Owners'),
                                SizedBox(height: 6),
                                Text('2,560'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text('Assets'),
                                SizedBox(height: 6),
                                Text('8,333'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}
