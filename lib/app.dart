import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/raid/domain/repositories/raid_repository.dart';
import 'features/raid/presentation/cubit/raid_cubit.dart';
import 'features/raid/presentation/pages/raid_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({required this.raidRepository, super.key});

  final RaidRepository raidRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RaidCubit>(
      create: (_) => RaidCubit(raidRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aether',
        theme: AppTheme.dark,
        home: const RaidPage(),
      ),
    );
  }
}
