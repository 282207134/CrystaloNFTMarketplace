import 'package:flutter/material.dart';

void go(BuildContext context, int id, {bool replace = false}) {
  if (replace) {
    Navigator.of(context).pushReplacementNamed('/screen/$id');
  } else {
    Navigator.of(context).pushNamed('/screen/$id');
  }
}

void back(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    go(context, 5, replace: true);
  }
}

void message(BuildContext context, String text) => ScaffoldMessenger.of(context)
    .showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );

const screenNames = <String>[
  'Splashscreen',
  'Onboarding',
  'Sign in',
  'Select a wallet',
  'Homescreen',
  'Homescreen · mobile',
  'Notifications',
  'Categories',
  'Top sellers',
  'Top creators',
  'Art collection',
  'Search',
  'Search results',
  'Filter · full',
  'Filter · mobile',
  'Filter sheet · full',
  'Filter sheet · mobile',
  'NFT ranking',
  'Ranking · expanded',
  'Collection · items',
  'Collection · activity',
  'NFT details · mobile',
  'Share NFT',
  'NFT · details',
  'NFT · bids',
  'NFT · owners',
  'NFT · history',
  'Place a bid',
  'Bid success · sheet',
  'Bid success · dialog',
  'Purchase',
  'Purchase success · sheet',
  'Purchase success · dialog',
  'Profile · collected',
  'Profile · owned',
  'Edit profile',
  'Create NFT',
  'Create success',
  'List · fixed price',
  'List · auction',
  'Listing success',
  'More',
  'My wallet',
  'Send ETH',
  'Receive ETH',
  'Buy ETH',
  'Swap ETH',
  'Settings',
  'Notification settings',
  'Help center',
];
