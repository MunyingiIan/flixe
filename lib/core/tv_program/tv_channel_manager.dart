import 'package:flutter/services.dart';
import 'package:flixstar/features/movie/data/models/movie_model.dart';

class TvChannelManager {
  static const platform = MethodChannel('flixstar/tv_channel');
  static const String channelId = "trending_movies_channel";
  static const String channelName = "Trending Movies";
  static const String channelDesc = "Shows trending movies from Flixstar";

  Future<void> createChannel() async {
    try {
      await platform.invokeMethod('createChannel', {
        'channelId': channelId,
        'channelName': channelName,
        'channelDescription': channelDesc,
      });
    } catch (e) {
      print('Error creating TV channel: $e');
    }
  }

  Future<void> updatePrograms(List<Movie> movies) async {
    try {
      final programs = movies
          .map((movie) => {
                'programId': movie.id.toString(),
                'title': movie.title ?? '',
                'description': movie.overview ?? '',
                'posterUrl': movie.posterPath ?? '',
                'intentUri': 'flixstar://movie/${movie.id}',
              })
          .toList();

      await platform.invokeMethod('updatePrograms', {
        'channelId': channelId,
        'programs': programs,
      });
    } catch (e) {
      print('Error updating TV programs: $e');
    }
  }
}
