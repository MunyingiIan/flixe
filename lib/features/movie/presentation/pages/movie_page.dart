import 'dart:io';

import 'package:flixstar/api/api.dart';
import 'package:flixstar/features/movie/presentation/widgets/app_bar.dart';
import 'package:flixstar/features/movie/presentation/widgets/overview.dart';
import 'package:flixstar/features/movie/presentation/widgets/related_movie.dart';
import 'package:flixstar/injection_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flixstar/features/movie/data/models/movie_model.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:flixstar/features/movie/presentation/widgets/movie_trailer.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final startAppSdk = sl<StartAppSdk>();
  StartAppBannerAd? bannerAd;
  List<MovieVideo> trailers = [];

  @override
  void initState() {
    super.initState();
    _loadTrailers();
    if (!kIsWeb) {
      if (!Platform.isWindows) {
        startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((bannerAd) {
          setState(() {
            this.bannerAd = bannerAd;
          });
        }).onError<StartAppException>((ex, stackTrace) {
          debugPrint("Error loading Banner ad: ${ex.message}");
        }).onError((error, stackTrace) {
          debugPrint("Error loading Banner ad: $error");
        });
      }
    }
  }

  Future<void> _loadTrailers() async {
    final api = sl<API>();
    final movieTrailers = await api.getMovieTrailers(widget.movie.id!);
    setState(() {
      trailers = movieTrailers;
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (!kIsWeb) {
      if (!Platform.isWindows) {
        bannerAd?.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        buildAppBar(context, widget.movie),
        buildOverview(widget.movie),
        MovieTrailer(trailers: trailers),
        // buildBannerAD(bannerAd),
        buildSimilarMovies(context)
      ],
    );
  }
}

SliverToBoxAdapter buildBannerAD(StartAppBannerAd? bannerAd) {
  if (!kIsWeb) {
    if (!Platform.isWindows) {
      return SliverToBoxAdapter(
        child: bannerAd == null
            ? SizedBox()
            : SizedBox(height: 50, child: StartAppBanner(bannerAd)),
      );
    }
  }
  return SliverToBoxAdapter(child: SizedBox());
}
