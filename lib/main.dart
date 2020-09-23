import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travego/providers/auth.dart';
import 'package:travego/providers/places.dart';
import 'package:travego/screens/auth.dart';
import 'package:travego/screens/details.dart';
import 'package:travego/screens/map.dart';
import 'package:travego/screens/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Places(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Travego',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            primaryColor: Colors.deepPurpleAccent,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.isAuth
              ? MapScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            AuthScreen.routeName: (ctx) => AuthScreen(),
            MapScreen.routeName: (ctx) => MapScreen(),
            DetailsScreen.routeName: (ctx) => DetailsScreen(),
          },
        ),
      ),
    );
  }
}
