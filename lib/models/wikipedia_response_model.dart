class WikipediaResponseModel {
  final String searchString;
  final List<String> suggestions;
  final List<String> wikipediaArticlesUrls;

  WikipediaResponseModel({
    required this.searchString,
    required this.suggestions,
    required this.wikipediaArticlesUrls,
  });

  factory WikipediaResponseModel.fromJson(Map<String, dynamic> json) {
    return WikipediaResponseModel(
      searchString: json['searchString'],
      suggestions: List<String>.from(json['suggestions']),
      wikipediaArticlesUrls: List<String>.from(json['wikipediaArticlesUrls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchString': searchString,
      'suggestions': suggestions,
      'wikipediaArticlesUrls': wikipediaArticlesUrls,
    };
  }
}
