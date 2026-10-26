import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../data/app_store.dart';
import '../data/catalog.dart';

class ArtImage extends StatelessWidget {
  const ArtImage(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.fit = BoxFit.cover,
    this.upload,
  });
  final String name;
  final String? upload;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: upload != null
        ? Image.memory(
            base64Decode(upload!),
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
          )
        : Image.asset(
            'assets/images/$name.png',
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
          ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 48, this.upload});
  final String name;
  final double size;
  final String? upload;
  @override
  Widget build(BuildContext context) =>
      ArtImage(name, width: size, height: size, radius: size, upload: upload);
}

class Verified extends StatelessWidget {
  const Verified({super.key, this.size = 17});
  final double size;
  @override
  Widget build(BuildContext context) =>
      Icon(Icons.verified_rounded, color: C.gold, size: size);
}

class GoldButton extends StatelessWidget {
  const GoldButton(
    this.label, {
    super.key,
    required this.onTap,
    this.outline = false,
    this.secondary = false,
    this.icon,
    this.height = 56,
  });
  final String label;
  final VoidCallback? onTap;
  final bool outline, secondary;
  final IconData? icon;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: height,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: outline
            ? Colors.transparent
            : secondary
            ? C.raised
            : C.gold,
        foregroundColor: outline || secondary ? C.gold : C.background,
        side: outline ? const BorderSide(color: C.gold) : null,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        textStyle: type(height <= 40 ? 13 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          if (icon != null) ...[
            const SizedBox(width: 10),
            Icon(icon, size: 20),
          ],
        ],
      ),
    ),
  );
}

class RoundAction extends StatelessWidget {
  const RoundAction(
    this.icon, {
    super.key,
    required this.onTap,
    this.size = 40,
    this.color = C.gold,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final String? tooltip;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: IconButton.filled(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: C.raised,
        foregroundColor: color,
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: size * .53),
    ),
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.trailing, this.leading});
  final String title;
  final Widget? trailing, leading;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 24),
    child: Row(
      children: [
        leading ??
            RoundAction(
              Icons.arrow_back_rounded,
              onTap: () => back(context),
              tooltip: 'Back',
            ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(title, style: type(22, weight: FontWeight.w600)),
        ),
        ?trailing,
      ],
    ),
  );
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.title,
    this.bottom,
    this.navIndex,
    this.scroll = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.trailing,
  });
  final Widget child;
  final String? title;
  final Widget? bottom, trailing;
  final int? navIndex;
  final bool scroll;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: navIndex != null,
    body: SafeArea(
      bottom: false,
      minimum: const EdgeInsets.only(top: 44),
      child: scroll
          ? SingleChildScrollView(
              padding: padding.copyWith(bottom: navIndex != null ? 140 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) PageHeader(title!, trailing: trailing),
                  child,
                ],
              ),
            )
          : Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) PageHeader(title!, trailing: trailing),
                  Expanded(child: child),
                ],
              ),
            ),
    ),
    bottomNavigationBar: navIndex != null
        ? BottomNav(navIndex!)
        : bottom == null
        ? null
        : SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: bottom!,
          ),
  );
}

class BottomNav extends StatelessWidget {
  const BottomNav(this.selected, {super.key});
  final int selected;
  @override
  Widget build(BuildContext context) {
    const labels = ['Explore', 'Ranking', 'Profile', 'More'];
    const icons = [
      Icons.map_outlined,
      Icons.show_chart_rounded,
      Icons.person_outline_rounded,
      Icons.more_horiz_rounded,
    ];
    const ids = [5, 18, 34, 42];
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 32,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (i) => Expanded(
              flex: i == selected ? 2 : 1,
              child: Semantics(
                label: labels[i],
                selected: selected == i,
                button: true,
                child: InkWell(
                  key: ValueKey('nav-$i'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    if (i != selected) go(context, ids[i], replace: true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected == i ? C.background : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[i],
                          size: 26,
                          color: selected == i ? C.gold : C.muted,
                        ),
                        if (selected == i) ...[
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              labels[i],
                              style: type(16, color: C.gold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
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

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.onTap,
    this.action = 'See all',
  });
  final String title, action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: type(20, weight: FontWeight.w600)),
        ),
        if (onTap != null)
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Text(action, style: type(16, color: C.gold)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: C.gold, size: 22),
              ],
            ),
          ),
      ],
    ),
  );
}

class Segments extends StatelessWidget {
  const Segments(
    this.labels, {
    super.key,
    required this.selected,
    required this.onChanged,
    this.underline = false,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final bool underline;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: underline ? null : C.card,
      borderRadius: BorderRadius.circular(8),
      border: underline
          ? const Border(bottom: BorderSide(color: C.raised))
          : null,
    ),
    padding: EdgeInsets.all(underline ? 0 : 3),
    child: Row(
      children: List.generate(
        labels.length,
        (i) => Expanded(
          child: InkWell(
            onTap: () => onChanged(i),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
              decoration: BoxDecoration(
                color: !underline && i == selected ? C.gold : null,
                borderRadius: BorderRadius.circular(6),
                border: underline && i == selected
                    ? const Border(bottom: BorderSide(color: C.gold, width: 3))
                    : null,
              ),
              child: Text(
                labels[i],
                maxLines: 1,
                style: type(
                  13,
                  color: i == selected
                      ? (underline ? C.gold : C.background)
                      : C.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class NftCard extends StatelessWidget {
  const NftCard(this.nft, {super.key});
  final Nft nft;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      AppScope.read(context).selectedNft = nft;
      go(context, 22);
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 166 / 135,
            child: ArtImage(nft.image, upload: nft.upload),
          ),
          const SizedBox(height: 8),
          Text(
            nft.name,
            style: type(14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Avatar(nft.avatar, size: 22),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  nft.collection,
                  style: type(10, color: C.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${eth(nft.price)} ETH',
                    style: type(13, color: C.gold, weight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
        ],
      ),
    ),
  );
}

class NftGrid extends StatelessWidget {
  const NftGrid(this.items, {super.key});
  final List<Nft> items;
  @override
  Widget build(BuildContext context) => items.isEmpty
      ? const EmptyState(
          'No items yet',
          'Explore the market or create your first NFT.',
        )
      : LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: items
                  .map((n) => SizedBox(width: width, child: NftCard(n)))
                  .toList(),
            );
          },
        );
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hint = 'Collection, item or user',
    this.autofocus = false,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hint;
  final bool autofocus;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          readOnly: onTap != null,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: C.muted,
              size: 22,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 48,
        height: 48,
        child: IconButton.filled(
          onPressed: () => go(context, 17),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: C.raised,
          ),
          icon: const Icon(Icons.tune_rounded, color: C.gold),
        ),
      ),
    ],
  );
}

class Field extends StatelessWidget {
  const Field(
    this.label, {
    super.key,
    required this.controller,
    this.hint,
    this.icon,
    this.lines = 1,
    this.keyboard,
    this.validator,
    this.suffix,
    this.readOnly = false,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final int lines;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: type(14)),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: controller,
          maxLines: lines,
          keyboardType: keyboard,
          validator: validator,
          readOnly: readOnly,
          style: type(14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: C.muted, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    ),
  );
}

class KeyValue extends StatelessWidget {
  const KeyValue(
    this.label,
    this.value, {
    super.key,
    this.color = Colors.white,
  });
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: type(12, color: C.muted)),
        ),
        Text(value, style: type(13, color: color)),
      ],
    ),
  );
}

class Stats extends StatelessWidget {
  const Stats(this.values, {super.key});
  final List<(String, String)> values;
  @override
  Widget build(BuildContext context) => Row(
    children: values
        .map(
          (s) => Expanded(
            child: Column(
              children: [
                Text(s.$1, style: type(15)),
                const SizedBox(height: 5),
                Text(
                  s.$2,
                  style: type(11, color: C.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.title, this.subtitle, {super.key});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 52),
    child: Center(
      child: Column(
        children: [
          const Icon(Icons.grid_view_rounded, color: C.gold, size: 42),
          const SizedBox(height: 16),
          Text(title, style: type(18)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: type(13, color: C.muted),
          ),
        ],
      ),
    ),
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72, this.color = C.gold});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _BrandPainter(color));
}

class _BrandPainter extends CustomPainter {
  _BrandPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = size.center(Offset.zero), r = size.width / 2;
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * math.pi / 3, b = a + math.pi / 3;
      final p1 = center + Offset(math.cos(a), math.sin(a)) * r;
      final p2 = center + Offset(math.cos(b), math.sin(b)) * r;
      final centroid = (center + p1 + p2) / 3;
      Offset shrink(Offset p) => centroid + (p - centroid) * .78;
      final p = Path()
        ..moveTo(shrink(center).dx, shrink(center).dy)
        ..lineTo(shrink(p1).dx, shrink(p1).dy)
        ..lineTo(shrink(p2).dx, shrink(p2).dy)
        ..close();
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(_BrandPainter oldDelegate) => oldDelegate.color != color;
}
