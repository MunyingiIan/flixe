import 'package:flixstar/common/widgets/other_options.dart';
import 'package:flixstar/features/library/presentation/bloc/library_bloc.dart';
import 'package:flixstar/features/library/presentation/bloc/library_event.dart';
import 'package:flixstar/features/library/presentation/bloc/library_state.dart';
import 'package:flixstar/features/movie/data/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

SliverToBoxAdapter buildotherOptions(BuildContext context, Movie movie) {
  return SliverToBoxAdapter(
    child: SizedBox(
      // height: 500,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, libState) {
                if (libState is LoadedLibraryState) {
                  return OtherOptions(
                    iconData: libState.movies.contains(movie)
                        ? Icon(
                            Icons.favorite,
                            color: Colors.pink,
                          )
                        : Icon(
                            Icons.favorite_border,
                          ),
                    text:
                        libState.movies.contains(movie) ? 'Remove' : 'My List',
                    onPressed: () {
                      !libState.movies.contains(movie)
                          ? context
                              .read<LibraryBloc>()
                              .add(AddMovieToLibrary(movie))
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
            OtherOptions(iconData: Icon(Icons.movie_outlined), text: 'Trailer'),
            OtherOptions(iconData: Icon(Icons.report_sharp), text: 'Report'),
            OtherOptions(iconData: Icon(Icons.share), text: 'Share')
          ],
        ),
      ),
    ),
  );
}
