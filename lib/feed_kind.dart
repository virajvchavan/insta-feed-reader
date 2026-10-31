enum FeedKind {
  favorites('Favorites', 'https://www.instagram.com/?variant=favorites'),
  following('Following', 'https://www.instagram.com/?variant=following');

  const FeedKind(this.label, this.url);

  final String label;
  final String url;
}
