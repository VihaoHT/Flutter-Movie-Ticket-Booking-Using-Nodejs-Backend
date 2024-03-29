import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:movie_booking_app/core/constants/constants.dart';
import 'package:movie_booking_app/core/constants/ultis.dart';
import 'package:movie_booking_app/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieRespository {
  String api = "$uri/api/movies";

  // Client
  Future<List<Movie>> getMovies() async {
    // Define the base URL and the endpoint
    final url = Uri.parse(api);

    // Make the HTTP GET request and await the response
    final response = await http.get(url);

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Parse the response body as a map of JSON objects
      final Map<String, dynamic> data = jsonDecode(response.body);
      //print(data);

      // Get the list of movies from the data map
      final List<dynamic> movies = data['data']['data'];
      // print(movies);
      // Map each JSON object to a Movie instance and return the list
      //only status == true can be in List
      // here i check device for admin panel if mobile the status will be true
      // you can also do other way if u want
      if (Platform.isAndroid || Platform.isIOS) {
        final List<Movie> filteredMovies = movies
            .where((movie) => movie['status'] == true)
            .map((filteredMovie) => Movie.fromJson(filteredMovie))
            .toList();

        return filteredMovies;
      } else {
        return movies.map((movie) => Movie.fromJson(movie)).toList();
      }
    } else {
      // Throw an exception if the response status code is not 200
      throw Exception('Failed to load movies');
    }
  }

  // Admin
  // Future<List<Movie>> getMoviesAdmin() async {
  //   // Define the base URL and the endpoint
  //   final url = Uri.parse(api);
  //
  //   // Make the HTTP GET request and await the response
  //   final response = await http.get(url);
  //
  //   // Check if the response status code is 200 (OK)
  //   if (response.statusCode == 200) {
  //     // Parse the response body as a map of JSON objects
  //     final Map<String, dynamic> data = jsonDecode(response.body);
  //     //print(data);
  //
  //     // Get the list of movies from the data map
  //     final List<dynamic> movies = data['data']['data'];
  //     // print(movies);
  //     // Map each JSON object to a Movie instance and return the list
  //     //only status == true can be in List
  //     return movies.map((movie) => Movie.fromJson(movie)).toList();
  //   } else {
  //     // Throw an exception if the response status code is not 200
  //     throw Exception('Failed to load movies');
  //   }
  // }

  // Client
  Future<List<Movie>> getMoviesByNameAndCategory(
      String category, String title) async {
    // check if category and title is null
    if ((category == null || category.isEmpty) &&
        (title == null || title.isEmpty)) {
      // return [] if category and title is null;
      return getMovies();
    }

    String apiSearch = "$uri/api/movies?";

    if (category != null && category.isNotEmpty) {
      apiSearch += "category=$category";
    }

    if (title != null && title.isNotEmpty) {
      apiSearch += "${category.isEmpty ? '' : '&'}title=$title";
    }

    // Define the base URL and the endpoint
    final url = Uri.parse(apiSearch);

    // Make the HTTP GET request and await the response
    final response = await http.get(url);

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Parse the response body as a map of JSON objects
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Get the list of movies from the data map
      final List<dynamic> movies = data['data']['data'];
      //same as  getMovies()
      final List<Movie> filteredMovies = movies
          .where((movie) => movie['status'] == true)
          .map((filteredMovie) => Movie.fromJson(filteredMovie))
          .toList();

      return filteredMovies;

      //print(movies);
    } else {
      // Throw an exception if the response status code is not 200
      throw Exception('Failed to load movies ${response.statusCode}');
    }
  }

  Future<List<Movie>> getMoviesByNameAdmin(String title) async {
    if (title.isEmpty) {
      // return [] if category and title is null;
      return getMovies();
    }

    String apiSearch = "$uri/api/movies?title=$title";

    // Define the base URL and the endpoint
    final url = Uri.parse(apiSearch);

    // Make the HTTP GET request and await the response
    final response = await http.get(url);

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Parse the response body as a map of JSON objects
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Get the list of movies from the data map
      final List<dynamic> movies = data['data']['data'];
      //same as  getMovies()
      // final List<Movie> filteredMovies = movies
      //     .where((movie) => movie['status'] == true)
      //     .map((filteredMovie) => Movie.fromJson(filteredMovie))
      //     .toList();
      //
      // return filteredMovies;
      if (Platform.isAndroid || Platform.isIOS) {
        final List<Movie> filteredMovies = movies
            .where((movie) => movie['status'] == true)
            .map((filteredMovie) => Movie.fromJson(filteredMovie))
            .toList();

        return filteredMovies;
      } else {
        return movies.map((movie) => Movie.fromJson(movie)).toList();
      }
      //print(movies);
    } else {
      // Throw an exception if the response status code is not 200
      throw Exception('Failed to load movies ${response.statusCode}');
    }
  }

  // Admin
  Future<List<Movie>> postNewMovie(
      File image,
      File video,
      String title,
      String release_date,
      String duration,
      List<String> category,
      List<String> actor,
      String description,
      BuildContext context) async {
    try {
      Dio dio = Dio();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('token');

      // Use the correct Content-Type header
      final options = Options(
        headers: {
          'Content-Type': 'application/json' 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      FormData formData = FormData.fromMap({
        'imageCover': await MultipartFile.fromFile(
          image.path,
        ),
        'trailer': await MultipartFile.fromFile(
          video.path,
        ),
        'title': title,
        'release_date': release_date,
        'duration': duration,
        'category': category,
        'actor': actor,
        'description': description
      });

      Response response = await dio.post(
        api,
        data: formData,
        options: options,
      );
      if (response.statusCode == 201) {
        if (context.mounted) {
          navigator!.pop(context);
          showToastSuccess(context, "Movie added succesfully!");
        }
        return getMovies();
      } else {
        return getMovies();
      }
    } catch (e) {
      throw Exception("failed");
    }
  }

  // Admin
  Future<List<Movie>> updateStatusMovie(
      bool status, String movieId, BuildContext context) async {
    String api = "$uri/api/movies/id/$movieId";
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    final res = (await http.patch(Uri.parse(api),
        body: json.encode({
          'status': status,
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        }));
    if (res.statusCode == 200) {
      // print("Update status successfully!");
      return getMovies();
    } else {
      if (context.mounted) {
        showToastFailed(context, "Update status failed! ${res.statusCode}");
      }
      return getMovies();
    }
  }

  //Admin
  Future<List<Movie>> updateMovie(
      String title,
      String release_date,
      String duration,
      String description,
      String movieId,
      BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String api = "$uri/api/movies/id/$movieId";
    final res = await http.patch(Uri.parse(api),
        body: json.encode({
          'title': title,
          'release_date': release_date,
          'duration': duration,
          'description': description
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });
    if (res.statusCode == 200) {
      if (context.mounted) {
        navigator!.pop(context);
        showToastSuccess(context, 'Movie update successfully!');
      }

      return getMovies();
    } else if (res.statusCode == 500) {
      if (context.mounted) {
        showToastWarning(context, "Movie update failed! ${res.reasonPhrase}");
      }
      return getMovies();
    }
    return getMovies();
  }

  //Admin
  Future<List<Movie>> updateCategory(
      List<String> category, String movieId, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String api = "$uri/api/movies/id/$movieId";
    final res = await http.patch(Uri.parse(api),
        body: json.encode({
          'category': category,
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });
    if (res.statusCode == 200) {
      if (context.mounted) {
        navigator!.pop(context);
        showToastSuccess(context, 'Movie update successfully!');
      }

      return getMovies();
    } else if (res.statusCode == 500) {
      if (context.mounted) {
        showToastWarning(context, "Movie update failed! ${res.reasonPhrase}");
      }
      return getMovies();
    }
    return getMovies();
  }

  //Admin
  Future<List<Movie>> updateActor(
      List<Object> actor, String movieId, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String api = "$uri/api/movies/id/$movieId";
    final res = await http.patch(Uri.parse(api),
        body: json.encode({
          'actor': actor,
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });
    if (res.statusCode == 200) {
      if (context.mounted) {
        navigator!.pop(context);
        showToastSuccess(context, 'Movie update successfully!');
      }

      return getMovies();
    } else if (res.statusCode == 500) {
      if (context.mounted) {
        showToastWarning(context, "Movie update failed! ${res.reasonPhrase}");
      }
      return getMovies();
    }
    return getMovies();
  }

  // Admin
  Future deleteMovie(String movieId, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String api = "$uri/api/movies/id/$movieId";
    final res = await http.delete(Uri.parse(api), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 204) {
      if (context.mounted) {
        navigator!.pop(context);
        showToastSuccess(context, 'The movie have been deleted!');
      }

      return getMovies();
    } else {
      if (context.mounted) {
        showToastWarning(
            context, "The movie cannot be delete! cuz: ${res.reasonPhrase}");
      }
      return getMovies();
    }
  }
}
