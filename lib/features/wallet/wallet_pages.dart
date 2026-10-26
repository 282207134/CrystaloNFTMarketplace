import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

Future<bool> confirmDemo(
  BuildContext context,
  String title,
  String detail,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(
          '$detail\n\nThis updates the demo balance on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
    false;

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final balance = store.balance
        .toStringAsFixed(store.balance == store.balance.roundToDouble() ? 0 : 4)
        .replaceFirstMapped(
          RegExp(r'^(\d+)(\d{3})(\.|$)'),
          (m) => '${m[1]},${m[2]}${m[3]}',
        );
    return AppPage(
      title: 'My Wallet',
      child: Column(
        children: [
          const Avatar('wallet_avatar', size: 96),
          const SizedBox(height: 20),
          Text('Current Wallet Balance', style: type(14, color: C.muted)),
          const SizedBox(height: 10),
          Text('$balance ETH', style: type(36, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Clipboard.setData(
                const ClipboardData(text: AppStore.walletAddress),
              );
              message(context, 'Wallet address copied');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: C.raised),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/metamask.svg',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 8),
                  Text('0x1467B4eF…6789Eab24', style: type(12, color: C.muted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (i) => Column(
                children: [
                  RoundAction(
                    [
                      Icons.send_outlined,
                      Icons.shopping_cart_outlined,
                      Icons.arrow_circle_down_outlined,
                      Icons.tune,
                    ][i],
                    onTap: () => go(context, [44, 46, 45, 47][i]),
                    size: 56,
                    tooltip: ['Send', 'Buy', 'Receive', 'Swap'][i],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['Send', 'Buy', 'Receive', 'Swap'][i],
                    style: type(14, color: C.gold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Segments(
            const ['Token', 'NFT'],
            selected: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          const SizedBox(height: 24),
          if (tab == 0) ...[
            _token(
              '◆',
              C.raised,
              '${eth(store.balance)} ETH',
              '\$840.35',
              () => go(context, 44),
            ),
            _token(
              '₮',
              const Color(0xFF12AA65),
              '67.5676 USDT',
              '\$67.56',
              () => _tokenDetails('USDT', 67.5676),
            ),
            _token(
              '◈',
              C.gold,
              '35.32768 DAI',
              '\$28.76',
              () => _tokenDetails('DAI', 35.32768),
            ),
            if (store.maticBalance > 0)
              _token(
                '⬡',
                const Color(0xFF8247E5),
                '${eth(store.maticBalance)} MATIC',
                'Demo balance',
                () => _tokenDetails('MATIC', store.maticBalance),
              ),
            if (store.transactions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const SectionTitle('Recent activity'),
              ...store.transactions
                  .take(8)
                  .map(
                    (t) => KeyValue(
                      t['type'],
                      '${eth((t['amount'] as num).toDouble())} ETH',
                    ),
                  ),
            ],
          ] else
            NftGrid(
              store.allNfts
                  .where(
                    (n) =>
                        store.owned.contains(n.id) ||
                        store.created.any((c) => c.id == n.id),
                  )
                  .toList(),
            ),
          const SizedBox(height: 16),
          Text(
            'Local demo wallet · prices are illustrative',
            style: type(11, color: C.dim),
          ),
        ],
      ),
    );
  }

  Widget _token(
    String symbol,
    Color color,
    String amount,
    String fiat,
    VoidCallback onTap,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 17,
          backgroundColor: color,
          child: Text(symbol, style: type(23)),
        ),
        title: Text(amount, style: type(16)),
        subtitle: Text(fiat, style: type(12, color: C.muted)),
        trailing: const Icon(Icons.chevron_right),
      ),
    ),
  );
  void _tokenDetails(String token, double amount) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(token, style: type(24)),
          const SizedBox(height: 20),
          Text('${eth(amount)} $token', style: type(28, color: C.gold)),
          const SizedBox(height: 20),
          Text(
            'This token is part of the demo portfolio. ETH transfer and ETH → MATIC swap flows are available from My Wallet.',
            style: type(14, color: C.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class SendEthPage extends StatefulWidget {
  const SendEthPage({super.key});
  @override
  State<SendEthPage> createState() => _SendEthPageState();
}

class _SendEthPageState extends State<SendEthPage> {
  final form = GlobalKey<FormState>();
  final recipient = TextEditingController(), amount = TextEditingController();
  String? error;
  @override
  void dispose() {
    recipient.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (!await confirmDemo(
          context,
          'Send ETH',
          'Send ${amount.text} ETH to\n${recipient.text}?',
        ) ||
        !mounted) {
      return;
    }
    try {
      await AppScope.read(context)
          .send(recipient.text.trim(), double.tryParse(amount.text) ?? 0);
      if (mounted) {
        message(context, 'Demo transfer completed');
        go(context, 43, replace: true);
      }
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Send ETH',
    bottom: GoldButton('Continue', onTap: send),
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Field(
            '',
            controller: recipient,
            hint: 'Recipient Address',
            suffix: IconButton(
              tooltip: 'Paste address',
              onPressed: () async {
                final clip = await Clipboard.getData(Clipboard.kTextPlain);
                if (mounted) recipient.text = clip?.text ?? '';
              },
              icon: const Icon(Icons.content_paste, size: 20, color: C.gold),
            ),
            validator: (v) =>
                RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(v?.trim() ?? '')
                ? null
                : 'Enter a valid Ethereum address.',
          ),
          Field(
            '',
            controller: amount,
            hint: 'Amount ETH',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            suffix: TextButton(
              onPressed: () =>
                  amount.text = eth(AppScope.read(context).balance),
              child: const Text('MAX  ETH'),
            ),
            validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                ? 'Enter an amount greater than zero.'
                : null,
          ),
          if (error != null) Text(error!, style: type(13, color: C.red)),
          const SizedBox(height: 8),
          Text(
            'Demo transfer · no real ETH will be sent',
            style: type(11, color: C.dim),
          ),
        ],
      ),
    ),
  );
}

class ReceiveEthPage extends StatefulWidget {
  const ReceiveEthPage({super.key});
  @override
  State<ReceiveEthPage> createState() => _ReceiveEthPageState();
}

class _ReceiveEthPageState extends State<ReceiveEthPage> {
  String amount = '';
  String get payload => amount.isEmpty
      ? AppStore.walletAddress
      : 'ethereum:${AppStore.walletAddress}?value=${(double.parse(amount) * 1e18).round()}';
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Receive ETH',
    child: Column(
      children: [
        const SizedBox(height: 44),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: QrImageView(
            data: payload,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SelectableText(
          AppStore.walletAddress,
          style: type(11),
          textAlign: TextAlign.center,
        ),
        if (amount.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Requested: $amount ETH',
              style: type(16, color: C.gold),
            ),
          ),
        const SizedBox(height: 90),
        Text(
          'Send only Ethereum (ETH) to this address.\nSending any other coins may result in permanent loss.',
          style: type(13, color: C.muted, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Demo address · do not send real funds',
          style: type(12, color: C.gold),
        ),
        const SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _action('Copy', Icons.copy, () {
              Clipboard.setData(ClipboardData(text: payload));
              message(context, 'Address copied');
            }),
            _action('Set Amount', Icons.add, _setAmount),
            _action(
              'Share',
              Icons.share_outlined,
              () => SharePlus.instance.share(
                ShareParams(text: 'Crystalo demo receive address\n$payload'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  Widget _action(String label, IconData icon, VoidCallback action) => Column(
    children: [
      RoundAction(icon, onTap: action, size: 48),
      const SizedBox(height: 8),
      Text(label, style: type(13, color: C.gold)),
    ],
  );
  Future<void> _setAmount() async {
    final input = TextEditingController(text: amount);
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set amount (ETH)'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: input,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v == null || v.isEmpty
                ? null
                : (double.tryParse(v) ?? 0) > 0
                ? null
                : 'Enter a positive amount.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, input.text);
            },
            child: const Text('Set Amount'),
          ),
        ],
      ),
    );
    input.dispose();
    if (result != null && mounted) setState(() => amount = result);
  }
}

class BuyEthPage extends StatefulWidget {
  const BuyEthPage({super.key});
  @override
  State<BuyEthPage> createState() => _BuyEthPageState();
}

class _BuyEthPageState extends State<BuyEthPage> {
  String dollars = '150', provider = 'Binance Connect';
  Future<void> buy() async {
    final value = double.tryParse(dollars) ?? 0;
    if (value <= 0) {
      message(context, 'Enter an amount greater than zero.');
      return;
    }
    if (!await confirmDemo(
          context,
          'Buy ETH',
          'Simulate buying ${(value / 13889.146).toStringAsFixed(7)} ETH for \$$dollars?',
        ) ||
        !mounted) {
      return;
    }
    await AppScope.read(context).buy(value);
    if (mounted) {
      message(context, 'Demo ETH added to your wallet');
      go(context, 43, replace: true);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Buy ETH',
    scroll: false,
    trailing: Chip(
      label: Text('USD ›', style: type(12, color: C.background)),
      backgroundColor: C.gold,
    ),
    bottom: GoldButton('Continue', onTap: buy),
    child: Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\$$dollars', style: type(44, weight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(
                '${((double.tryParse(dollars) ?? 0) / 13889.146).toStringAsFixed(7)} ETH',
                style: type(14, color: C.muted),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              onTap: _provider,
              leading: const CircleAvatar(
                backgroundColor: C.gold,
                child: Icon(Icons.token, color: Colors.white),
              ),
              title: Text(provider, style: type(16)),
              subtitle: Text(
                'Third Party Provider · demo',
                style: type(12, color: C.muted),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2,
          children: List.generate(12, (i) {
            final label = i < 9
                ? '${i + 1}'
                : i == 10
                ? '0'
                : '';
            return TextButton(
              onPressed: i == 9
                  ? null
                  : () {
                      setState(() {
                        if (i == 11) {
                          dollars = dollars.length > 1
                              ? dollars.substring(0, dollars.length - 1)
                              : '0';
                        } else if (dollars.length < 7) {
                          dollars = dollars == '0' ? label : dollars + label;
                        }
                      });
                    },
              child: i == 11
                  ? const Icon(Icons.backspace_outlined, color: C.muted)
                  : Text(label, style: type(20)),
            );
          }),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
  Future<void> _provider() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Binance Connect', 'Coinbase Pay']
            .map(
              (s) => ListTile(
                title: Text('$s · demo'),
                trailing: provider == s
                    ? const Icon(Icons.check, color: C.gold)
                    : null,
                onTap: () => Navigator.pop(ctx, s),
              ),
            )
            .toList(),
      ),
    );
    if (result != null) setState(() => provider = result);
  }
}

class SwapEthPage extends StatefulWidget {
  const SwapEthPage({super.key});
  @override
  State<SwapEthPage> createState() => _SwapEthPageState();
}

class _SwapEthPageState extends State<SwapEthPage> {
  final amount = TextEditingController(text: '1');
  String? error;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> swap() async {
    final value = double.tryParse(amount.text) ?? 0;
    if (value <= 0) {
      setState(() => error = 'Enter a positive amount.');
      return;
    }
    if (!await confirmDemo(
          context,
          'Swap ETH',
          'Swap ${eth(value)} ETH for ${eth(value * 1577.822)} MATIC?',
        ) ||
        !mounted) {
      return;
    }
    try {
      await AppScope.read(context).swap(value);
      if (mounted) {
        message(context, 'Demo swap completed');
        go(context, 43, replace: true);
      }
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Swap ETH',
    bottom: GoldButton('Continue', onTap: swap),
    child: Column(
      children: [
        TextField(
          controller: amount,
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('◆ ETH ›', style: type(14)),
            ),
            errorText: error,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: C.gold,
          ),
          child: const Icon(Icons.south_rounded, color: C.background),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text('⬡ MATIC', style: type(14)),
              const Spacer(),
              Text(
                eth((double.tryParse(amount.text) ?? 0) * 1577.822),
                style: type(16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            for (final p in [25, 50, 75, 100])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GoldButton(
                    '$p%',
                    height: 32,
                    onTap: () => setState(
                      () => amount.text = eth(
                        AppScope.read(context).balance * p / 100,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('1 ETH = 1,577.822 MATIC', style: type(14)),
        const SizedBox(height: 16),
        Text(
          'Illustrative fixed rate · local demo swap',
          style: type(11, color: C.dim),
        ),
      ],
    ),
  );
}
