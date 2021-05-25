class Article {
  String source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String date;

  Article({
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.date,
  });

  Article.fromJson(Map map) {
    source = map['source'];
    author = map['source'];
    title = map['title'];
     description = map['excerpt'];
    url = map['url'];
    urlToImage = map['image'];
    date = map['date_news'];
  }
}
