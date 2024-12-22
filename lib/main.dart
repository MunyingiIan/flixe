import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flixstar/core/routes/routes.dart';
import 'package:flixstar/firebase_options.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flixstar/core/player/movie_player.dart';
import 'package:flixstar/core/player/tv_player.dart';
import 'package:flixstar/features/tv/presentation/bloc/tv_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flixstar/core/common/pages/update_screen.dart';
import 'package:flixstar/core/const/const.dart';
import 'package:flixstar/core/utils/theme_data.dart';
import 'package:flixstar/features/history/presentation/bloc/history_bloc.dart';
import 'package:flixstar/features/home/presentation/bloc/home_bloc.dart';
import 'package:flixstar/features/home/presentation/pages/home.dart';
import 'package:flixstar/features/library/presentation/bloc/library_bloc.dart';
import 'package:flixstar/features/movie/presentation/bloc/movie_bloc.dart';
import 'package:flixstar/features/search/presentation/bloc/search_bloc.dart';
import 'package:flixstar/injection_container.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize dependencies (which includes Firebase initialization)
  await initialiseDependencies();

  // Handle deep links for TV channel (if Android platform)
  if (Platform.isAndroid) {
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      handleDeepLink(initialUri);
    }

    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri);
      }
    });
  }

  // Run the app
  runApp(isUpdateAvailable ? UpdateWarningScreen() : App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(create: (context) => sl<HomeBloc>()),
          BlocProvider<MovieBloc>(create: (context) => sl<MovieBloc>()),
          BlocProvider<TvBloc>(create: (context) => sl<TvBloc>()),
          BlocProvider<LibraryBloc>(
              create: (context) => sl<LibraryBloc>()), // Library Bloc
          BlocProvider<HistoryBloc>(
              create: (context) => sl<HistoryBloc>()), // Episode Bloc
          BlocProvider<SearchBloc>(
              create: (context) => sl<SearchBloc>()), // History Bloc
        ],
        child: GetMaterialApp(
          title: 'Flix',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Home(),
          getPages: [
            GetPage(name: '/', page: () => Home()),
            GetPage(
                name: '/watch/movie/:mid',
                page: () {
                  final id = (Get.parameters['mid'] ?? 0);
                  return MoviePlayer(id: int.parse(id.toString()));
                }),
            GetPage(
                name: '/watch/tv/:tid',
                page: () {
                  final id = (Get.parameters['tid'] ?? 0);
                  return TvPlayer(id: int.parse(id.toString()));
                }),
          ],
        ));
  }
}
