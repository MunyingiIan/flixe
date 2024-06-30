import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixstar/common/pages/url_video_player.dart';
import 'package:flixstar/common/pages/video_player.dart';
import 'package:flixstar/common/widgets/details_chip.dart';
import 'package:flixstar/common/widgets/play_button.dart';
import 'package:flixstar/core/const/const.dart';
import 'package:flixstar/features/history/presentation/bloc/history_bloc.dart';
import 'package:flixstar/features/history/presentation/bloc/history_event.dart';
import 'package:flixstar/features/movie/data/models/movie_model.dart';
import 'package:flixstar/features/movie/presentation/bloc/movie_bloc.dart';
import 'package:flixstar/features/movie/presentation/bloc/movie_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

SliverAppBar buildAppBar(BuildContext context, Movie movie) {
  return SliverAppBar(
    primary: true,
    bottom: streamMode
        ? PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: BlocBuilder<MovieBloc, MovieState>(
                builder: (context, state) {
                  if (state is MovieLoadingState) {
                    return Center(
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator()),
                    );
                  } else if (state is MovieLoadedState) {
                    return PlayButton(
                      icon: Icon(state.sourceHtml != null
                          ? Icons.play_arrow
                          : Icons.info),
                      label: Text(
                          state.sourceHtml != null ? 'Play' : 'Coming Soon..'),
                      onPressed: () async {
                        if (state.sourceHtml != null) {
                          if (!context
                              .read<HistoryBloc>()
                              .state
                              .movies
                              .contains(movie)) {
                            context
                                .read<HistoryBloc>()
                                .add(AddToHistoryEvent(movie: movie));
                          }
                          if (kIsWeb) {
                            Get.to(
                                () => WebVideoPlayer(html: state.sourceHtml!));
                          } else {
                            if (Platform.isWindows) {
                              Get.to(() =>
                                  WebVideoPlayer(html: state.sourceHtml!));
                            }
                            if (Platform.isAndroid) {
                              Get.to(
                                  () => VideoPlayer(html: state.sourceHtml!));
                            }
                          }
                        } else {}
                      },
                    );
                  } else if (state is MovieErrorState) {
                    return Center(
                      child: PlayButton(
                          icon: Icon(Icons.warning_amber),
                          label: Text('Not Available'),
                          onPressed: () {}),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
          )
        : PreferredSize(preferredSize: Size.zero, child: SizedBox()),
    forceMaterialTransparency: true,
    // backgroundColor: Colors.black,
    expandedHeight: context.height * 0.5,
    pinned: true,
    flexibleSpace: FlexibleSpaceBar(
      // title: Text(movie.title ?? movie.name.toString()),
      collapseMode: CollapseMode.parallax,
      background: Container(
        // filter: ImageFilter.blur(sigmaX: 12,sigmaY: 12),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: CachedNetworkImageProvider(movie.posterPath.toString()),
                fit: BoxFit.cover)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
              decoration: BoxDecoration(
                  // color: Colors.black.withOpacity(0.2),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent.withOpacity(0.2),
                    Colors.black.withOpacity(0.9),
                  ])),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                      imageUrl: movie.posterPath.toString(),
                      height: context.height * 0.25),
                  SizedBox(height: 15),
                  Text(movie.title ?? movie.name.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    DetailsChip(
                        text: movie.originalLanguage.toString().toUpperCase()),
                    SizedBox(width: 15),
                    DetailsChip(
                        text: (DateTime.tryParse(movie.releaseDate.toString())
                                ?.year)
                            .toString()),
                    SizedBox(width: 15),
                    DetailsChip(text: movie.adult == true ? '18+' : '13+'),
                  ]),
                  SizedBox(
                    height: 25,
                  )
                ],
              )),
        ),
      ),
    ),
  );
}
