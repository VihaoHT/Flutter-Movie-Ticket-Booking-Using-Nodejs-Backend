import 'dart:convert';

import 'package:http/http.dart';
import 'package:movie_booking_app/core/constants/constants.dart';
import 'package:movie_booking_app/models/movie_model.dart';

class Top5Respository {

  String apiTop5 = "$uri/api/movies/top-5";
  Future<List<Movie>> getTop5Movies() async {
    // Define the base URL and the endpoint
    final url = Uri.parse(apiTop5);

    // Make the HTTP GET request and await the response
    final response = await get(url);

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Parse the response body as a map of JSON objects
      final Map<String, dynamic> data = jsonDecode(response.body);
      //print(data);

      // Get the list of movies from the data map
      final List<dynamic> movies = data['data']['data'];
      // print(movies);
      await Future.delayed(const Duration(seconds: 2));

      // Map each JSON object to a Movie instance and return the list
      return movies.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      // Throw an exception if the response status code is not 200
      throw Exception('Failed to load movies');
    }
  }
}
