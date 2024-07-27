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
}
