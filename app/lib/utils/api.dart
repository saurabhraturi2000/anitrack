import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getTrendingAnime() async {
  final url =
      Uri.parse('https://graphql.anilist.co'); // AniList GraphQL API endpoint

  final query = '''
    query {
      Page(page: 1, perPage: 10) { # Adjust page and perPage as needed
        media(type: ANIME, sort: TRENDING_DESC) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            large
          }
          startDate {
            year
            month
            day
          }
          endDate {
            year
            month
            day
          }
          status
          episodes
          season
          averageScore
          popularity
          genres
          description
        }
      }
    }
  ''';

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': query}),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    //print(jsonEncode(jsonData)); // Useful for debugging

    // Extract the anime data from the response.  Handle potential nulls.
    final animeListData = jsonData['data']?['Page']?['media'] as List<dynamic>?;

    if (animeListData != null) {
      return animeListData;
    } else {
      print('Error: Could not parse anime data from response.');
      return []; // Return an empty list in case of an error
    }
  } else {
    print('Error: Request failed with status code: ${response.statusCode}');
    print(response.body); // Print the error response for debugging
    return []; // Return an empty list in case of an error
  }
}

// Example usage:
void main() async {
  final trendingAnime = await getTrendingAnime();

  if (trendingAnime.isNotEmpty) {
    print('Trending Anime:');
    for (final anime in trendingAnime) {
      print('Title: ${anime['title']['romaji']}');
      print('Cover Image: ${anime['coverImage']['large']}');
      // ... print other properties
      print('---');
    }
  } else {
    print('Could not retrieve trending anime.');
  }
}
