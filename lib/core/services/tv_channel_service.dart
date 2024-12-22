import 'package:flixstar/features/movie/data/models/movie_model.dart';
import 'package:flixstar/injection_container.dart';
import 'package:flixstar/core/tv_program/tv_channel_manager.dart';
import 'package:flixstar/api/api.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TvChannelService {
  final API _api = sl<API>();
  final _channelManager = TvChannelManager();

  Future<void> updateTrendingMoviesChannel() async {
    try {
      final response = await _api.tmdb.v3.trending.getTrending(
        mediaType: MediaType.movie,
        timeWindow: TimeWindow.day,
      );

      final movies = (response['results'] as List)
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();

      await _channelManager.updatePrograms(movies);
    } catch (e) {
      print('Error updating TV channel: $e');
    }
  }
}
