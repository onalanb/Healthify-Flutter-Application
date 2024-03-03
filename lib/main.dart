// Baran Onalan
// January 6th, 2024

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'login.dart';
import 'recording.dart';
import 'style_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Delete the hive boxes to start fresh
  //await Hive.deleteBoxFromDisk('RecordingProviderBox');

  await Hive.openBox<Map<dynamic, dynamic>>('EmotionBox');
  await Hive.openBox<Map<dynamic, dynamic>>('DietBox');
  await Hive.openBox<Map<dynamic, dynamic>>('WorkoutBox');
  await Hive.openBox<String>('FoodDropdownBox');
  await Hive.openBox<dynamic>('RecordingProviderBox');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => RecordingProvider()),
          Provider<StyleOptions>(
            create: (_) => StyleOptions(WidgetStyle.material), // .cupertino is the other provider.
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Login(),
          ),
        )
    ),
  );
}

/******************************************************************************/

