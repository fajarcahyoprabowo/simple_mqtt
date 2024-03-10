import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_mqtt/core/injection.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_cubit.dart';
import 'package:simple_mqtt/data/hive_config.dart';
import 'package:simple_mqtt/pages/mqtt_broker/mqtt_broker_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDepedencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<MqttCubit>()..init(),
        ),
      ],
      child: ValueListenableBuilder(
        valueListenable: getIt<Box>().listenable(),
        builder: (_, box, child) {
          final isDarkMode = box.get(HiveConfig.DARK_MODE_KEY);
          final themeMode =
              (isDarkMode == true) ? ThemeMode.dark : ThemeMode.light;

          return MaterialApp(
            title: 'Flutter MQTT',
            themeMode: themeMode,
            darkTheme: ThemeData.dark(
              useMaterial3: false,
            ).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                inversePrimary: Colors.yellow,
                primaryContainer: Colors.black38,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
              textTheme: GoogleFonts.poppinsTextTheme().apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
                decorationColor: Colors.white,
              ),
            ),
            theme: ThemeData.light(
              useMaterial3: false,
            ).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: child,
          );
        },
        child: const MQTTBrokerPage(),
      ),
    );
  }
}
