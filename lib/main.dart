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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initialiseDependencies();
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
          title: 'Flixe',
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
