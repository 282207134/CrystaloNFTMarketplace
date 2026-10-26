class Nft {
  const Nft({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.collection = 'MetaGlow XI',
    this.avatar = 'avatar_metaglow',
    this.description = '',
    this.upload,
  });
  final String id, name, image, collection, avatar, description;
  final double price;
  final String? upload;

  Nft withPrice(double value) => Nft(
    id: id,
    name: name,
    image: image,
    price: value,
    collection: collection,
    avatar: avatar,
    description: description,
    upload: upload,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'price': price,
    'collection': collection,
    'avatar': avatar,
    'description': description,
    'upload': upload,
  };
  factory Nft.fromJson(Map<String, dynamic> json) => Nft(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    price: (json['price'] as num).toDouble(),
    collection: json['collection'],
    avatar: json['avatar'],
    description: json['description'] ?? '',
    upload: json['upload'],
  );
}

const metaglow = [
  Nft(id: '271', name: 'MetaGlow #271', image: 'nft_gold', price: .87),
  Nft(id: '171', name: 'MetaGlow #171', image: 'nft_silver', price: 1.04),
  Nft(id: '21', name: 'MetaGlow #21', image: 'nft_green', price: .19),
  Nft(id: '81', name: 'MetaGlow #81', image: 'nft_blue', price: .28),
  Nft(id: '154', name: 'MetaGlow #154', image: 'nft_yellow', price: .20),
  Nft(id: '189', name: 'MetaGlow #189', image: 'nft_rose', price: .11),
  Nft(id: '27', name: 'MetaGlow #27', image: 'nft_jade', price: .07),
  Nft(id: '76', name: 'MetaGlow #76', image: 'nft_lime', price: .258),
];
const trending = [
  Nft(id: '2178', name: 'ZapiRobo #2178', image: 'robot', price: .49),
  Nft(id: '4678', name: 'DidioFlox #4678', image: 'pumpkin', price: .39),
];
const leaves = [
  Nft(
    id: 'leaf24',
    name: 'Leafier #24',
    image: 'leaf_red',
    price: .19,
    collection: 'Leafier Skull',
    avatar: 'avatar_leaf',
  ),
  Nft(
    id: 'leaf109',
    name: 'Leafier #109',
    image: 'leaf_white',
    price: .29,
    avatar: 'avatar_leaf',
  ),
  Nft(
    id: 'leaf133',
    name: 'Leafier #133',
    image: 'leaf_blue',
    price: .19,
    avatar: 'avatar_leaf',
  ),
  Nft(
    id: 'leaf56',
    name: 'Leafier #56',
    image: 'leaf_yellow',
    price: .07,
    avatar: 'avatar_leaf',
  ),
  Nft(
    id: 'leaf62',
    name: 'Leafier #62',
    image: 'leaf_blue',
    price: .18,
    avatar: 'avatar_leaf',
  ),
  Nft(
    id: 'leaf123',
    name: 'Leafier #123',
    image: 'leaf_lily',
    price: .20,
    avatar: 'avatar_leaf',
  ),
];
const categories = [
  'Art',
  'Collectible',
  'Music',
  'Photography',
  'Sports',
  'Memes',
];
const categoryImages = [
  'category_art',
  'category_collectible',
  'category_music',
  'category_photo',
  'category_sports',
  'category_memes',
];
const sellers = [
  (name: 'KNS_Khass', image: 'seller_khass', amount: '22.5 ETH'),
  (name: 'ToraKus', image: 'avatar_torakus', amount: '18.5 ETH'),
  (name: 'Bungash', image: 'avatar_bungash', amount: '17.5 ETH'),
  (name: 'Mohtas', image: 'avatar_mohtas', amount: '14.5 ETH'),
];
const creators = [
  (name: 'Moazily', image: 'avatar_moazily', cover: 'creator_cover_1'),
  (name: 'TorchWarrior', image: 'avatar_torch', cover: 'creator_cover_2'),
  (name: 'PandaNando', image: 'avatar_panda', cover: 'creator_cover_3'),
];
const ranking = [
  (name: 'Bluesea Ape', image: 'rank_ape', amount: '228.72', change: '83.49%'),
  (
    name: 'Crypto Shine',
    image: 'rank_shine',
    amount: '185.59',
    change: '13.16%',
  ),
  (name: 'Cargo Ring', image: 'rank_ring', amount: '184.3', change: '-12.22%'),
  (
    name: 'Skeleton Mapa',
    image: 'rank_mapa',
    amount: '136.99',
    change: '504.47%',
  ),
  (name: 'Karchi Pose', image: 'rank_pose', amount: '132.07', change: '7.87%'),
];

String eth(double value) => value
    .toStringAsFixed(4)
    .replaceFirst(RegExp(r'0+$'), '')
    .replaceFirst(RegExp(r'\.$'), '');
