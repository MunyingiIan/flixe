// ignore_for_file: unused_import

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flixstar/core/const/constants.dart';
import 'package:flixstar/injection_container.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:html/parser.dart';

import '../features/movie/data/models/movie_model.dart';
import '../features/tv/data/models/tv_model.dart';

class API {
  final TMDB _tmdb = TMDB(
      ApiKeys(dotenv.get('APIKEY'), dotenv.get('ACCESS_TOKEN')),
      defaultLanguage: 'en-US');
  TMDB get tmdb => _tmdb;

  String getMovieSource(int id) {
    String movieUrl = '$vidSrcBaseUrl/embed/movie/$id';
    log('Getting Movie Source from url $movieUrl');
    return movieUrl;
  }

  String getTvSource(int id) {
    String tvUrl = '$vidSrcBaseUrl/embed/tv/$id';
    return tvUrl;
  }

  Future<List<MovieVideo>> getMovieTrailers(int movieId) async {
    final response = await tmdb.v3.movies.getVideos(movieId);
    final results = response['results'] as List;

    // Filter for YouTube trailers only
    return results
        .map((video) => MovieVideo.fromJson(video))
        .where((video) =>
            video.site.toLowerCase() == 'youtube' &&
            video.type.toLowerCase() == 'trailer')
        .toList();
  }

  Future<List<TvVideo>> getTvTrailers(int tvId) async {
    final response = await tmdb.v3.tv.getVideos(tvId.toString());
    final results = response['results'] as List;

    // Filter for YouTube trailers only
    return results
        .map((video) => TvVideo.fromJson(video))
        .where((video) =>
            video.site.toLowerCase() == 'youtube' &&
            video.type.toLowerCase() == 'trailer')
        .toList();
  }
}
