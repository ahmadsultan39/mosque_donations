import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/mosque_type/presentation/bloc/mosque_type_bloc.dart';
import 'features/mosque_type/presentation/pages/type_selection_page.dart';
import 'features/pricing/presentation/bloc/pricing_bloc.dart';
import 'features/pricing/presentation/pages/pricing_form_page.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تبرعات المساجد',
      theme: appTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (_) =>
            BlocProvider(
              create: (context) => MosqueTypeBloc(),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TypeSelectionPage(),
              ),
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/form' && settings.arguments != null) {
          final type = settings.arguments as dynamic;
          return MaterialPageRoute(
            builder: (_) =>
                BlocProvider(
                  create: (context) => PricingBloc(),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: PricingFormPage(type: type),
                  ),
                ),
          );
        }
        return null;
      },
    );
  }
}
