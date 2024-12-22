import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cast/cast.dart';
import 'package:flixstar/api/api.dart';
import 'package:flixstar/core/common/widgets/details_chip.dart';
import 'package:flixstar/core/common/widgets/dns_dialogue.dart';
import 'package:flixstar/core/common/widgets/play_button.dart';
import 'package:flixstar/core/const/const.dart';
import 'package:flixstar/features/history/presentation/bloc/history_bloc.dart';
import 'package:flixstar/features/history/presentation/bloc/history_event.dart';
import 'package:flixstar/features/library/presentation/bloc/library_bloc.dart';
import 'package:flixstar/features/library/presentation/bloc/library_event.dart';
import 'package:flixstar/features/library/presentation/bloc/library_state.dart';
import 'package:flixstar/features/movie/data/models/movie_model.dart';
import 'package:flixstar/features/movie/presentation/bloc/movie_bloc.dart';
import 'package:flixstar/features/movie/presentation/bloc/movie_state.dart';
import 'package:flixstar/injection_container.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';



SliverAppBar buildAppBar(BuildContext context, Movie movie) {
  return SliverAppBar(
    primary: true,
    actions: [
      BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, libState) {
          if (libState is LoadedLibraryState) {
            return IconButton(
              icon: libState.movies.contains(movie)
                  ? Icon(
                      Icons.favorite,
                      color: Colors.pink,
                    )
                  : Icon(
                      Icons.favorite_border,
                    ),
              onPressed: () {
                !libState.movies.contains(movie)
                    ? context.read<LibraryBloc>().add(AddMovieToLibrary(movie))
                    : context
                        .read<LibraryBloc>()
                        .add(RemoveMovieFromLibrary(movie));
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    ],
    bottom: streamMode
        ? PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoadingState) {
              return Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is MovieLoadedState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlayButton(
                    icon: Icon(Icons.play_arrow),
                    label: Text('Play'),
                    onPressed: () async {
                      if (!context.read<HistoryBloc>().state.movies.contains(movie)) {
                        context.read<HistoryBloc>().add(AddToHistoryEvent(movie: movie));
                      }
                      // Navigate to movie player
                      Get.toNamed('/watch/movie/${movie.id}', parameters: {'mid': movie.id.toString()});
                    },
                  ),
                  // SizedBox(height: 16), // Add spacing between buttons
                  // ElevatedButton.icon(
                  //   icon: Icon(Icons.cast),
                  //   label: Text('Cast to TV'),
                  //   onPressed: () async {
                  //     final api = sl<API>();
                  //     final iframeUrl = api.getMovieSource(movie.id!);
                  //
                  //     // Discover cast devices
                  //     final discoveryService = CastDiscoveryService();
                  //     final devices = await discoveryService.search(timeout: Duration(seconds: 5));
                  //     if (devices.isEmpty) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(content: Text('No cast devices found.')),
                  //       );
                  //       return;
                  //     }
                  //
                  //     // Use a persistent context
                  //     final persistentContext = context;
                  //
                  //     // Show device selection
                  //     showModalBottomSheet(
                  //       context: persistentContext,
                  //       builder: (context) {
                  //         return ListView(
                  //           children: devices.map((device) {
                  //             return ListTile(
                  //               title: Text(device.name),
                  //               subtitle: Text('${device.host}:${device.port}'),
                  //               onTap: () async {
                  //                 Navigator.pop(context); // Close the modal
                  //                 try {
                  //                   // Log: Attempting to connect
                  //                   debugPrint('Attempting to connect to device: ${device.name}');
                  //
                  //                   final sessionManager = CastSessionManager();
                  //                   final session = await sessionManager.startSession(device);
                  //
                  //                   // Log: Connection success
                  //                   debugPrint('Successfully connected to ${device.name}');
                  //
                  //                   // Send a LOAD command without await since it returns void
                  //                   session.sendMessage(
                  //                     CastSession.kNamespaceMedia,
                  //                     {
                  //                       'type': 'LOAD',
                  //                       'media': {
                  //                         'contentId': iframeUrl, // Replace with your content
                  //                         'streamType': 'BUFFERED',
                  //                         'contentType': 'text/html',
                  //                       },
                  //                       'autoplay': true,
                  //                     },
                  //                   );
                  //
                  //                   ScaffoldMessenger.of(persistentContext).showSnackBar(
                  //                     SnackBar(content: Text('Casting to ${device.name}')),
                  //                   );
                  //                   debugPrint('Successfully started casting to ${device.name}');
                  //                 } catch (e) {
                  //                   // Log: Connection error
                  //                   debugPrint('Error connecting to device: ${device.name}, Error: $e');
                  //                   ScaffoldMessenger.of(persistentContext).showSnackBar(
                  //                     SnackBar(content: Text('Error casting: $e')),
                  //                   );
                  //                 }
                  //               },
                  //             );
                  //           }).toList(),
                  //         );
                  //       },
                  //     );
                  //   },
                  // ),
                ],
              );
            } else {
              return Center(
                child: PlayButton(
                  icon: Icon(Icons.help),
                  label: Text('Not Available'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => dnsDialogue(context),
                    );
                  },
                ),
              );
            }
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
