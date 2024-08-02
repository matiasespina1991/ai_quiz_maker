import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../models/wikipedia_response_model.dart';

class WikipediaService {
  Future<WikipediaResponseModel> fetchSuggestions(
      String query, Locale locale) async {
    if (query.isEmpty) {
      return WikipediaResponseModel(
        searchString: query,
        suggestions: [],
        wikipediaArticlesUrls: [],
      );
    }

    final response = await http.get(
      Uri.parse(
          'https://${locale.languageCode}.wikipedia.org/w/api.php?action=opensearch&format=json&profile=fuzzy&search=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return WikipediaResponseModel(
        searchString: data[0] as String,
        suggestions: List<String>.from(data[1]),
        wikipediaArticlesUrls: List<String>.from(data[3]),
      );
    } else {
      print('Failed to fetch suggestions: ${response.body}');
      throw Exception('Failed to fetch suggestions');
    }
  }

  Future<String> fetchArticleContent(
      String articleUrl, String languageCode) async {
    final articleTitle = articleUrl.split('/').last;
    final apiUrl =
        'https://${languageCode}.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exlimit=max&explaintext&titles=$articleTitle';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pages = data['query']['pages'];
      final page = pages.values.first;
      return page['extract'] as String;
    } else {
      print('Failed to fetch article content: ${response.body}');
      throw Exception('Failed to fetch article content');
    }
  }
}
