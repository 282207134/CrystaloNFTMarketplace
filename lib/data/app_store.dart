import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

class MarketFilter {
  String sort = 'Recently Created',
      status = 'Buy Now',
      category = 'All',
      chain = 'All Chains';
  RangeValues range = const RangeValues(.01, 10);
  void clear() {
    sort = 'Recently Created';
    status = 'Buy Now';
    category = 'All';
    chain = 'All Chains';
    range = const RangeValues(.01, 10);
  }

  List<Nft> apply(Iterable<Nft> source) {
    var items = source
        .where((n) => n.price >= range.start && n.price <= range.end)
        .toList();
    if (category != 'All') {
      items = items
          .where(
            (n) => category == 'Art'
                ? n.image.startsWith('nft_') || n.image.startsWith('leaf_')
                : category == 'Collectible'
                ? ['robot', 'pumpkin'].contains(n.image)
                : false,
          )
          .toList();
    }
    if (status == 'On Auction') {
      items = items.where((n) => n.id == '271').toList();
    }
    if (status == 'Offer Available') {
      items = items.where((n) => n.price < .3).toList();
    }
    if (status == 'New') items = items.reversed.take(4).toList();
    if (sort == 'Low to High') items.sort((a, b) => a.price.compareTo(b.price));
    if (sort == 'High to Low') items.sort((a, b) => b.price.compareTo(a.price));
    if (sort == 'Most Viewed') items = items.reversed.toList();
    return items;
  }
}

class AppStore extends ChangeNotifier {
  AppStore([this.preferences]) {
    _restore();
  }
  final SharedPreferences? preferences;
  Set<String> favorites = {}, following = {}, owned = {};
  List<Nft> created = [];
  List<Map<String, dynamic>> transactions = [];
  Map<String, Map<String, dynamic>> itemOptions = {}, listings = {};
  Map<String, double> bids = {};
  String username = 'Leafier Skulls',
      email = '',
      bio = '',
      walletProvider = 'MetaMask';
  String? profileImage;
  Map<String, String> social = {};
  String language = 'English (US)';
  double balance = 2786, maticBalance = 0;
  double get highestBid =>
      bids[selectedNft.id] ??
      (selectedNft.id == '271' ? .85 : selectedNft.price * .98);
  bool signedIn = false, offers = true;
  List<bool> notifications = [true, false, true, false, false, true];
  final filter = MarketFilter();
  Nft selectedNft = metaglow.first;
  String selectedCategory = 'Art';
  static const walletAddress = '0x1467B4eF7A423e2cC43d315A56dF4a06789Eab24';
  Iterable<Nft> get allNfts => [
    ...metaglow,
    ...trending,
    ...leaves,
    ...created,
  ];

  void _restore() {
    final raw = preferences?.getString('crystalo.state');
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      favorites = Set<String>.from(d['favorites'] ?? []);
      following = Set<String>.from(d['following'] ?? []);
      owned = Set<String>.from(d['owned'] ?? []);
      created = (d['created'] as List? ?? [])
          .map((n) => Nft.fromJson(Map<String, dynamic>.from(n)))
          .toList();
      transactions = (d['transactions'] as List? ?? [])
          .map((t) => Map<String, dynamic>.from(t))
          .toList();
      username = d['username'] ?? username;
      email = d['email'] ?? '';
      bio = d['bio'] ?? '';
      profileImage = d['profileImage'];
      social = Map<String, String>.from(d['social'] ?? {});
      language = d['language'] ?? language;
      walletProvider = d['walletProvider'] ?? walletProvider;
      balance = (d['balance'] as num? ?? balance).toDouble();
      maticBalance = (d['maticBalance'] as num? ?? 0).toDouble();
      bids = (d['bids'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      itemOptions = (d['itemOptions'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
      );
      listings = (d['listings'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
      );
      signedIn = d['signedIn'] ?? false;
      offers = d['offers'] ?? true;
      notifications = List<bool>.from(d['notifications'] ?? notifications);
    } on FormatException {
      /* A damaged local cache falls back to the demo catalog. */
    }
  }

  Future<void> save() async {
    notifyListeners();
    await preferences?.setString(
      'crystalo.state',
      jsonEncode({
        'favorites': favorites.toList(),
        'following': following.toList(),
        'owned': owned.toList(),
        'created': created.map((n) => n.toJson()).toList(),
        'transactions': transactions,
        'username': username,
        'email': email,
        'bio': bio,
        'profileImage': profileImage,
        'social': social,
        'language': language,
        'balance': balance,
        'maticBalance': maticBalance,
        'bids': bids,
        'itemOptions': itemOptions,
        'listings': listings,
        'signedIn': signedIn,
        'walletProvider': walletProvider,
        'offers': offers,
        'notifications': notifications,
      }),
    );
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    save();
  }

  void toggleFollow(String name) {
    following.contains(name) ? following.remove(name) : following.add(name);
    save();
  }

  void _record(String type, double amount, {String? name}) {
    transactions.insert(0, {
      'type': type,
      'amount': amount,
      'name': name ?? selectedNft.name,
      'time': DateTime.now().toIso8601String(),
    });
  }

  void _checkAmount(double amount) {
    if (!amount.isFinite || amount <= 0) {
      throw const FormatException('Enter an amount greater than zero.');
    }
  }

  Future<void> bid(double amount) async {
    _checkAmount(amount);
    if (amount <= highestBid) {
      throw FormatException('Your bid must exceed ${eth(highestBid)} ETH.');
    }
    if (amount > balance) {
      throw const FormatException('Insufficient demo balance.');
    }
    bids[selectedNft.id] = amount;
    _record('Bid', amount);
    await save();
  }

  Future<void> purchase() async {
    if (owned.contains(selectedNft.id)) {
      throw const FormatException('This NFT is already in your collection.');
    }
    if (balance < selectedNft.price) {
      throw const FormatException('Insufficient demo balance.');
    }
    balance -= selectedNft.price;
    owned.add(selectedNft.id);
    _record('Purchase', selectedNft.price);
    await save();
  }

  Future<void> send(String address, double amount) async {
    if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) {
      throw const FormatException(
        'Enter a valid Ethereum address (0x + 40 hex characters).',
      );
    }
    _checkAmount(amount);
    if (amount > balance) {
      throw const FormatException('Insufficient demo balance.');
    }
    balance -= amount;
    _record('Send', amount, name: address);
    await save();
  }

  Future<void> buy(double usd) async {
    _checkAmount(usd);
    final amount = usd / 13889.146;
    balance += amount;
    _record('Buy', amount, name: 'Demo provider');
    await save();
  }

  Future<void> swap(double amount) async {
    _checkAmount(amount);
    if (amount > balance) {
      throw const FormatException('Insufficient demo balance.');
    }
    balance -= amount;
    maticBalance += amount * 1577.822;
    _record('Swap', amount, name: 'ETH → MATIC');
    await save();
  }

  Future<Nft> createNft({
    required String title,
    required String description,
    required double price,
    required String collection,
    String? upload,
    bool unlockable = false,
    bool putOnSale = true,
    bool instantSale = false,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      throw const FormatException('A title and description are required.');
    }
    _checkAmount(price);
    final nft = Nft(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      name: title.trim(),
      image: 'leaf_new',
      price: price,
      collection: collection,
      avatar: 'avatar_leaf',
      description: description,
      upload: upload,
    );
    created.insert(0, nft);
    itemOptions[nft.id] = {
      'unlockable': unlockable,
      'putOnSale': putOnSale,
      'instantSale': instantSale,
    };
    selectedNft = nft;
    await save();
    return nft;
  }

  Future<void> listSelected(
    double price,
    bool auction, {
    bool unlockable = false,
    String start = 'Right after listing',
    String expiration = '3 Days',
  }) async {
    _checkAmount(price);
    listings[selectedNft.id] = {
      'price': price,
      'auction': auction,
      'unlockable': unlockable,
      'start': start,
      'expiration': expiration,
    };
    selectedNft = selectedNft.withPrice(price);
    final index = created.indexWhere((n) => n.id == selectedNft.id);
    if (index >= 0) created[index] = selectedNft;
    _record(auction ? 'Auction listing' : 'Fixed price listing', price);
    await save();
  }
}

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  static AppStore read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
