import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../shared/widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.autoAdvance = true});
  final bool autoAdvance;
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    if (widget.autoAdvance) {
      _timer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) {
          go(context, AppScope.read(context).signedIn ? 5 : 2, replace: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.gold,
    body: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: C.background,
            ),
            child: const BrandMark(size: 34),
          ),
          const SizedBox(width: 10),
          Text(
            'Crystalo',
            style: type(28, color: C.background, weight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, box) {
          final scale = box.maxWidth / 428;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 24 * scale,
                        top: -199 * scale,
                        width: 116 * scale,
                        height: 726 * scale,
                        child: const ArtImage(
                          'onboarding_left',
                          fit: BoxFit.fill,
                          radius: 0,
                        ),
                      ),
                      Positioned(
                        left: 156 * scale,
                        top: -35 * scale,
                        width: 116 * scale,
                        height: 464 * scale,
                        child: const ArtImage(
                          'onboarding_center',
                          fit: BoxFit.fill,
                          radius: 0,
                        ),
                      ),
                      Positioned(
                        left: 288 * scale,
                        top: -199 * scale,
                        width: 116 * scale,
                        height: 726 * scale,
                        child: const ArtImage(
                          'onboarding_right',
                          fit: BoxFit.fill,
                          radius: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover, Collect\nand Sell Awesome\nPrecious NFTS',
                      style: type(
                        math.min(36, 36 * scale),
                        weight: FontWeight.w700,
                        height: 1.23,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore the top collection of NFTs and\nbuy and sell your NFTs as well.',
                      style: type(16, color: C.muted, height: 1.5),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 32),
                child: GoldButton(
                  'Get Started',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () => go(context, 3),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _password = TextEditingController();
  bool _remember = false, _hidden = true, _register = false;
  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit({String? provider}) async {
    if (provider == null && !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final store = AppScope.read(context);
    store.signedIn = true;
    if (_name.text.trim().isNotEmpty) store.username = _name.text.trim();
    await store.save();
    if (mounted) {
      if (provider != null) message(context, '$provider demo session started.');
      go(context, 4);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: IconButton(
              onPressed: () => back(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Center(
            child: Container(
              width: 145,
              height: 145,
              decoration: const BoxDecoration(
                color: C.raised,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const BrandMark(size: 105),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _register ? 'Join Crystalo,' : 'Welcome,',
            style: type(36, weight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            _register ? 'Create your demo account!' : 'Sign in to continue!',
            style: type(22, color: C.muted),
          ),
          const SizedBox(height: 32),
          TextFormField(
            key: const ValueKey('username'),
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter your username.' : null,
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const ValueKey('password'),
            controller: _password,
            obscureText: _hidden,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Use at least 6 characters.' : null,
          ),
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Checkbox(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v!),
                  side: const BorderSide(color: C.gold),
                ),
              ),
              const SizedBox(width: 4),
              const Text('Remember me'),
            ],
          ),
          const SizedBox(height: 12),
          GoldButton(
            _register ? 'Create account' : 'Sign in',
            key: const ValueKey('sign-in'),
            onTap: () => _submit(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Or continue with',
                  style: type(14, color: C.muted),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          for (final provider in ['Google', 'Apple']) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => _submit(provider: provider),
                style: TextButton.styleFrom(
                  backgroundColor: C.card,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    provider == 'Apple'
                        ? const Icon(Icons.apple, size: 28)
                        : Text(
                            'G',
                            style: type(
                              28,
                              color: const Color(0xFF4285F4),
                              weight: FontWeight.w700,
                            ),
                          ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Continue with $provider',
                        style: type(14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Center(
            child: TextButton(
              onPressed: () => setState(() => _register = !_register),
              child: Text.rich(
                TextSpan(
                  style: type(14, color: C.muted),
                  children: [
                    TextSpan(
                      text: _register ? 'Already a member? ' : 'Not a member? ',
                    ),
                    TextSpan(
                      text: _register ? 'Sign in' : 'Register now',
                      style: const TextStyle(color: C.gold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class WalletConnectPage extends StatelessWidget {
  const WalletConnectPage({super.key});
  Future<void> _connect(BuildContext context, String name) async {
    final store = AppScope.read(context);
    store.walletProvider = name;
    store.signedIn = true;
    await store.save();
    if (context.mounted) {
      message(context, '$name demo wallet connected');
      go(context, 5, replace: true);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    child: Column(
      children: [
        const PageHeader(''),
        const SizedBox(height: 6),
        const ArtImage('wallet', width: 119, height: 119, fit: BoxFit.contain),
        const SizedBox(height: 40),
        Text('Select a wallet', style: type(28, weight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(
          'By connecting your wallet, you agree to our\nTerms of Service and our Privacy Policy.',
          style: type(12, color: C.muted, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Wrap(
            spacing: 36,
            runSpacing: 32,
            children: List.generate(6, (i) {
              const names = [
                'MetaMask',
                'Coinbase',
                'Phantom',
                'Polygon',
                'Fortmatic',
                'More',
              ];
              const files = [
                'metamask',
                'coinbase',
                'phantom',
                'polygon',
                'fortmatic',
              ];
              return SizedBox(
                width: 72,
                child: InkWell(
                  onTap: () =>
                      i == 5 ? _address(context) : _connect(context, names[i]),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: C.raised,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: i == 5
                            ? const Icon(Icons.more_horiz)
                            : SvgPicture.asset('assets/images/${files[i]}.svg'),
                      ),
                      const SizedBox(height: 10),
                      Text(names[i], style: type(13)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Or', style: type(14, color: C.muted)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        GoldButton(
          'Enter Ethereum Address',
          outline: true,
          onTap: () => _address(context),
        ),
        const SizedBox(height: 20),
        Text(
          'Demo wallet · no real funds or wallet permissions',
          style: type(11, color: C.dim),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
  Future<void> _address(BuildContext context) async {
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connect demo address'),
        content: Form(
          key: key,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(hintText: '0x…'),
            validator: (v) => RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(v ?? '')
                ? null
                : 'Use a valid Ethereum address.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && context.mounted) await _connect(context, 'Address');
  }
}
