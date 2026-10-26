import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';
import '../nft/nft_pages.dart';

Future<String?> pickImage(BuildContext context) async {
  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length > 10 * 1024 * 1024) {
      if (context.mounted) {
        message(context, 'Choose an image smaller than 10 MB.');
      }
      return null;
    }
    return base64Encode(bytes);
  } catch (_) {
    if (context.mounted) {
      message(
        context,
        'The image picker is unavailable. You can use the sample artwork.',
      );
    }
    return null;
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.owned = false});
  final bool owned;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late int tab = widget.owned ? 2 : 0;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final items = tab == 0
        ? leaves
        : tab == 1
        ? store.created
        : [
            ...metaglow.take(4),
            ...store.allNfts.where(
              (n) =>
                  store.owned.contains(n.id) &&
                  !metaglow.take(4).any((m) => m.id == n.id),
            ),
          ];
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BottomNav(2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 150),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const ArtImage(
                  'profile_cover',
                  width: double.infinity,
                  height: 300,
                  radius: 0,
                ),
                SafeArea(
                  minimum: const EdgeInsets.only(top: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Profile',
                            style: type(22, weight: FontWeight.w600),
                          ),
                        ),
                        RoundAction(
                          Icons.logout,
                          onTap: () async {
                            store.signedIn = false;
                            await store.save();
                            if (context.mounted) go(context, 3, replace: true);
                          },
                          tooltip: 'Sign out',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 172, 24, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 68, 20, 36),
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                store.username,
                                style: type(22, weight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Verified(size: 20),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          store.bio.isEmpty ? 'Artist/Creator' : store.bio,
                          style: type(16, color: C.muted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 113,
                              child: GoldButton(
                                'Edit Profile',
                                height: 40,
                                secondary: true,
                                onTap: () => go(context, 36),
                              ),
                            ),
                            const SizedBox(width: 10),
                            RoundAction(
                              Icons.add,
                              size: 40,
                              onTap: () => go(context, 37),
                              tooltip: 'Create NFT',
                            ),
                            const SizedBox(width: 10),
                            RoundAction(
                              Icons.more_horiz,
                              size: 40,
                              onTap: () => go(context, 48),
                              tooltip: 'Settings',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Stats([
                          ('15K', 'total volume'),
                          ('100%', 'unique owner'),
                          ('0.19 ETH', 'floor price'),
                          ('0.15 ETH', 'current bid'),
                        ]),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Avatar(
                      'avatar_leaf',
                      size: 104,
                      upload: store.profileImage,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Segments(
                    const ['Collected', 'Created', 'Owned'],
                    selected: tab,
                    onChanged: (i) => setState(() => tab = i),
                  ),
                  const SizedBox(height: 24),
                  NftGrid(items),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(
        text: AppScope.read(context).username,
      ),
      email = TextEditingController(text: AppScope.read(context).email),
      bio = TextEditingController(text: AppScope.read(context).bio);
  late final links = List.generate(
    4,
    (i) =>
        TextEditingController(text: AppScope.read(context).social['$i'] ?? ''),
  );
  String? image;
  @override
  void dispose() {
    for (final c in [name, email, bio, ...links]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final store = AppScope.read(context);
    store.username = name.text.trim();
    store.email = email.text.trim();
    store.bio = bio.text.trim();
    store.social = {
      for (var i = 0; i < links.length; i++) '$i': links[i].text.trim(),
    };
    store.profileImage = image ?? store.profileImage;
    await store.save();
    if (mounted) {
      message(context, 'Profile saved');
      go(context, 34, replace: true);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Edit Profile',
    bottom: GoldButton(
      'Save Changes',
      key: const ValueKey('save-profile'),
      onTap: save,
    ),
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    final result = await pickImage(context);
                    if (result != null && mounted) {
                      setState(() => image = result);
                    }
                  },
                  child:
                      image != null || AppScope.of(context).profileImage != null
                      ? Avatar(
                          'avatar_leaf',
                          size: 120,
                          upload: image ?? AppScope.of(context).profileImage,
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: C.card,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_outlined, color: C.muted),
                              const SizedBox(height: 6),
                              Text('Upload Image', style: type(10)),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text('Profile Image', style: type(16)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Field(
            'Username',
            controller: name,
            hint: 'Username',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Username is required.' : null,
          ),
          Field(
            'Email Address',
            controller: email,
            hint: 'Email address',
            icon: Icons.mail_outline,
            keyboard: TextInputType.emailAddress,
            validator: (v) =>
                v != null &&
                    v.isNotEmpty &&
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
                ? 'Enter a valid email address.'
                : null,
          ),
          Field('Bio', controller: bio, hint: 'Bio', lines: 3),
          Text('Social Links', style: type(14)),
          const SizedBox(height: 12),
          for (var i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                controller: links[i],
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: [
                    'https://example.com/collection/xyz',
                    'https://facebook.com/xyz',
                    'https://instagram.com/xyz',
                    'https://twitter.com/xyz',
                  ][i],
                  prefixIcon: Icon(
                    [
                      Icons.language,
                      Icons.facebook,
                      Icons.camera_alt_outlined,
                      Icons.alternate_email,
                    ][i],
                    size: 20,
                  ),
                ),
                validator: (v) =>
                    v != null &&
                        v.isNotEmpty &&
                        !(Uri.tryParse(v)?.hasScheme ?? false)
                    ? 'Enter a complete URL.'
                    : null,
              ),
            ),
        ],
      ),
    ),
  );
}

class CreateNftPage extends StatefulWidget {
  const CreateNftPage({super.key, this.success = false, this.listed = false});
  final bool success, listed;
  @override
  State<CreateNftPage> createState() => _CreateNftPageState();
}

class _CreateNftPageState extends State<CreateNftPage> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      description = TextEditingController(),
      price = TextEditingController(text: '0.19');
  String? upload;
  String collection = 'Leafier Skull';
  bool sample = false,
      unlock = false,
      sale = true,
      instant = false,
      busy = false;
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    if (upload == null && !sample) {
      message(context, 'Upload an image or use the sample artwork.');
      return;
    }
    setState(() => busy = true);
    final store = AppScope.read(context);
    await store.createNft(
      title: title.text,
      description: description.text,
      price: double.tryParse(price.text) ?? .19,
      collection: collection,
      upload: upload,
      unlockable: unlock,
      putOnSale: sale,
      instantSale: instant,
    );
    if (mounted) go(context, 38, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final page = AppPage(
      title: 'Add New Item',
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Image, Video, Audio or 3D Model', style: type(16)),
            const SizedBox(height: 8),
            Text(
              'Image upload supports JPG, PNG, GIF and WebP.\nMax size: 10 MB. Other media require a production service.',
              style: type(11, color: C.muted, height: 1.5),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final result = await pickImage(context);
                if (result != null && mounted) setState(() => upload = result);
              },
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: upload != null || sample
                    ? ArtImage('leaf_new', upload: upload, radius: 16)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: C.muted,
                          ),
                          const SizedBox(height: 12),
                          Text('Upload Image', style: type(16)),
                        ],
                      ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() {
                  sample = true;
                  upload = null;
                }),
                child: const Text('Use sample artwork'),
              ),
            ),
            Field(
              'Title',
              controller: title,
              hint: 'e.g. “Crypto Boy”',
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Give your NFT a title.'
                  : null,
            ),
            Field(
              'Description',
              controller: description,
              hint: 'Enter a description here…',
              lines: 4,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Add a description.' : null,
            ),
            Text('Collection', style: type(14)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: collection,
              items: {
                'Leafier Skull',
                'MetaGlow XI',
                collection,
              }.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => collection = v!),
            ),
            TextButton.icon(
              onPressed: _addCollection,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add New Collection'),
            ),
            const SizedBox(height: 12),
            _toggle(
              'Unlockable content',
              'Content is unlocked after a successful transaction',
              unlock,
              (v) => unlock = v,
            ),
            _toggle(
              'Put on sale',
              'Make this item available for offers',
              sale,
              (v) => sale = v,
            ),
            _toggle(
              'Instant sale price',
              'Enter the price for an instant sale',
              instant,
              (v) => instant = v,
            ),
            if (instant)
              Field(
                'Price (ETH)',
                controller: price,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                    ? 'Enter a positive price.'
                    : null,
              ),
            const SizedBox(height: 24),
            GoldButton(
              busy ? 'Creating…' : 'Create an NFT',
              key: const ValueKey('create-nft'),
              onTap: busy ? null : submit,
            ),
            const SizedBox(height: 16),
            Text(
              'NFT creation is stored locally in this demo.',
              style: type(11, color: C.dim),
            ),
          ],
        ),
      ),
    );
    if (!widget.success) return page;
    final selected = AppScope.of(context).selectedNft;
    final nft = selected.id.startsWith('local-')
        ? selected
        : const Nft(
            id: 'leaf272',
            name: 'Leafier #272',
            image: 'leaf_new',
            price: .19,
            collection: 'Leafier Skull',
            avatar: 'avatar_leaf',
          );
    return SuccessOverlay(
      background: page,
      nft: nft,
      title: 'Congratulations',
      subtitle: widget.listed
          ? 'You have successfully listed an NFT.'
          : 'You have successfully created an NFT.',
      button: widget.listed ? 'View Collection' : 'List Item',
      onPrimary: () => go(context, widget.listed ? 34 : 39, replace: true),
    );
  }

  Widget _toggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> action,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: type(16)),
    subtitle: Text(subtitle, style: type(12, color: C.muted)),
    value: value,
    onChanged: (v) => setState(() => action(v)),
  );
  Future<void> _addCollection() async {
    final input = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: input,
          decoration: const InputDecoration(hintText: 'Collection name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (input.text.trim().isNotEmpty) {
                Navigator.pop(ctx, input.text.trim());
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    input.dispose();
    if (result != null && mounted) setState(() => collection = result);
  }
}

class ListingPage extends StatefulWidget {
  const ListingPage({super.key, this.auction = false});
  final bool auction;
  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  late int tab = widget.auction ? 1 : 0;
  final price = TextEditingController(text: '1');
  bool unlock = true;
  String start = 'Right after listing', end = '3 Days';
  String? error;
  @override
  void dispose() {
    price.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    try {
      await AppScope.read(context).listSelected(
        double.tryParse(price.text) ?? 0,
        tab == 1,
        unlockable: unlock,
        start: start,
        expiration: end,
      );
      if (mounted) go(context, 41, replace: true);
    } on FormatException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'List Item',
    bottom: GoldButton(
      'Continue',
      key: const ValueKey('confirm-listing'),
      onTap: submit,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Segments(
          const ['Fixed Price', 'Auction'],
          selected: tab,
          onChanged: (i) => setState(() => tab = i),
        ),
        const SizedBox(height: 24),
        Text(tab == 0 ? 'Fixed price' : 'Minimum Bid', style: type(22)),
        const SizedBox(height: 8),
        Text(
          'You’ll receive bids on this item',
          style: type(12, color: C.muted),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('◆ ETH ›', style: type(14)),
            ),
            errorText: error,
          ),
        ),
        const SizedBox(height: 24),
        if (tab == 0) ...[
          const KeyValue('Creator fee', '5%'),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.lock_outline, color: C.muted),
            title: Text('Unlockable content', style: type(16)),
            subtitle: Text(
              'Content will be unlocked after\na successful transaction',
              style: type(12, color: C.muted),
            ),
            value: unlock,
            onChanged: (v) => setState(() => unlock = v),
          ),
        ] else ...[
          Text('Starting Date', style: type(16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: start,
            isExpanded: true,
            items: [
              'Right after listing',
              'Tomorrow',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => start = v!),
          ),
          const SizedBox(height: 24),
          Text('Expiration Date', style: type(16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: end,
            isExpanded: true,
            items: [
              '1 Day',
              '3 Days',
              '7 Days',
              '30 Days',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => end = v!),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Demo listing · saved in your local activity',
          style: type(11, color: C.dim),
        ),
      ],
    ),
  );
}
