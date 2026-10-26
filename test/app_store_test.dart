import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crystalo/data/app_store.dart';
import 'package:crystalo/data/catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Purchase charges once and records ownership', () async {
    final store = AppStore();
    await store.purchase();
    expect(store.balance, closeTo(2785.13, .00001));
    expect(store.owned, contains('271'));
    expect(store.transactions.single['type'], 'Purchase');
    await expectLater(store.purchase(), throwsFormatException);
    expect(store.balance, closeTo(2785.13, .00001));
  });

  test('Bids must exceed current bid and available balance', () async {
    final store = AppStore();
    for (final amount in [double.nan, double.infinity, -1.0, 0.0, .8, 3000.0]) {
      await expectLater(store.bid(amount), throwsFormatException);
    }
    await store.bid(.9);
    expect(store.highestBid, .9);
    expect(store.balance, 2786);
  });

  test(
    'Transfers reject invalid address, non-positive and excess amounts',
    () async {
      final store = AppStore();
      await expectLater(store.send('bad-address', 1), throwsFormatException);
      await expectLater(
        store.send(AppStore.walletAddress, 0),
        throwsFormatException,
      );
      await expectLater(
        store.send(AppStore.walletAddress, 3000),
        throwsFormatException,
      );
      await store.send(AppStore.walletAddress, 1.5);
      expect(store.balance, 2784.5);
      expect(store.transactions.single['type'], 'Send');
    },
  );

  test('Demo buy and swap conserve their specified balances', () async {
    final store = AppStore();
    await store.buy(13889.146);
    expect(store.balance, closeTo(2787, .000001));
    await store.swap(1);
    expect(store.balance, closeTo(2786, .000001));
    expect(store.maticBalance, 1577.822);
  });

  test('Profile, favorites, settings, NFTs and transactions persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = AppStore(prefs);
    store.username = 'Pixso Collector';
    store.notifications[1] = true;
    store.toggleFavorite('271');
    store.toggleFollow('Moazily');
    final nft = await store.createNft(
      title: 'My artwork',
      description: 'Original art',
      price: .4,
      collection: 'Test Collection',
    );
    await store.save();
    final restored = AppStore(prefs);
    expect(restored.username, 'Pixso Collector');
    expect(restored.favorites, contains('271'));
    expect(restored.following, contains('Moazily'));
    expect(restored.notifications[1], isTrue);
    expect(restored.created.single.id, nft.id);
    expect(restored.created.single.collection, 'Test Collection');
  });

  test('Filters change ordering, category, price range and status', () {
    final f = MarketFilter()..sort = 'Low to High';
    final result = f.apply(metaglow);
    expect(result.first.price, .07);
    f.category = 'Collectible';
    expect(f.apply([...metaglow, ...trending]).length, 2);
    f.clear();
    f.status = 'On Auction';
    expect(f.apply(metaglow).single.id, '271');
  });

  test('Bids are isolated between NFTs', () async {
    final store = AppStore();
    await store.bid(.9);
    store.selectedNft = metaglow[1];
    await store.bid(1.2);
    store.selectedNft = metaglow.first;
    expect(store.highestBid, .9);
  });

  test(
    'Creating and listing preserve item options and the listed price',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = AppStore(prefs);
      final nft = await store.createNft(
        title: 'Leafier test',
        description: 'Test art',
        price: .2,
        collection: 'Leafier Skull',
        unlockable: true,
        instantSale: true,
      );
      await store.listSelected(
        1.5,
        true,
        start: 'Tomorrow',
        expiration: '7 Days',
      );
      final restored = AppStore(prefs);
      expect(restored.created.single.price, 1.5);
      expect(restored.itemOptions[nft.id]!['unlockable'], isTrue);
      expect(restored.listings[nft.id]!['auction'], isTrue);
      expect(restored.listings[nft.id]!['expiration'], '7 Days');
    },
  );
}
