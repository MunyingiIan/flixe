import 'package:flixstar/api/api.dart';
import 'package:flixstar/api/gogo_api.dart';
import 'package:flixstar/features/movie/data/models/movie_model.dart';
import 'package:flixstar/features/anime/data/models/source_model.dart';
import 'package:flixstar/features/anime/presentation/pages/all_episodes.dart';
import 'package:flixstar/features/anime/presentation/pages/anime_details.dart';
import 'package:flixstar/features/movie/presentation/bloc/movie_bloc.dart';
import 'package:flixstar/features/tv/data/models/tv_model.dart';
import 'package:flixstar/features/tv/presentation/bloc/tv_bloc.dart';
import 'package:flixstar/features/tv/presentation/pages/tv_page.dart';
import 'package:flixstar/injection_container.dart';
import 'package:flixstar/features/movie/presentation/pages/movie_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:jikan_api/jikan_api.dart';

Future<void> logScreenView(String routeName) async {
  await analytics.logScreenView(screenName: routeName, screenClass: routeName);
}

class DNavigator {
  // to movie details
  static Future<void> toMovieDetails(Movie movie) async {
    Get.to(() => Builder(builder: (context) {
          context.read<MovieBloc>().add(LoadMovieDetailEvent(movie: movie));
          return MovieDetailsPage(movie: movie);
        }));
    await logScreenView(movie.title ?? 'Movie Screen');
  }

  // to TV Details
  static void toTVDetails(TvModel tv) {
    Get.to(() => Builder(builder: (context) {
          context.read<TvBloc>().add(LoadTvEvent(tv: tv));
          return TvDetailsPage(tv: tv);
        }));
  }

  static void toAnimeDetails(Anime anime) {
    Get.to(
      () => AnimeDetailsPage(anime: anime),
    );
  }

  static void toAllEpisodes(Anime anime) {
    Get.to(() => FutureBuilder(
        future: _getAllEpisodes(anime),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: Center(
              child: CircularProgressIndicator(),
            ));
          } else {
            return AllEpisodes(anime: anime, animeSourceList: snapshot.data!);
          }
        }));
  }

  static Future<List<AnimeSource>> _getAllEpisodes(Anime anime) async {
    final GoAnime goAnime = GoAnime(sl());
    final sources =
        await goAnime.getEpisodesLinksOfAnime(anime, count: anime.episodes!);
    return sources;
  }
}

void handleDeepLink(Uri uri) {
  if (uri.host == 'movie') {
    final movieId = int.tryParse(uri.pathSegments.last);
    if (movieId != null) {
      // Navigate to movie details
      final api = sl<API>();
      api.tmdb.v3.movies.getDetails(movieId).then((response) {
        final movie = Movie.fromJson(response as Map<String, dynamic>);
        DNavigator.toMovieDetails(movie);
      });
    }
  }
}
