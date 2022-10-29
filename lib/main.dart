import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myshop/ui/products/user_products_screen.dart';
import 'package:provider/provider.dart';

import 'ui/screens.dart';

/* void main() {
  runApp(const MyApp());
} */

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthManager(),
          ),
          ChangeNotifierProxyProvider<AuthManager, ProductsManager>(
            create: (ctx) => ProductsManager(),
            update: (ctx, authManager, productsManager) {
              productsManager!.authToken = authManager.authToken;
              return productsManager;
            },
          ),
          ChangeNotifierProvider(
            create: (ctx) => CartManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => OrdersManager(),
          ),
        ],
        child: Consumer<AuthManager>(
          builder: (ctx, authManager, child) {
            return MaterialApp(
                title: 'My Shop',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  fontFamily: 'Lato',
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.purple,
                  ).copyWith(
                    secondary: Colors.deepOrange,
                  ),
                ),
                home: authManager.isAuth
                    ? const ProductsOverviewScreen()
                    : FutureBuilder(
                        future: authManager.tryAutoLogin(),
                        builder: ((context, snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const SplashScreen()
                              : const AuthScreen();
                        }),
                      ),
                routes: {
                  CartScreen.routeName: (ctx) => const CartScreen(),
                  OrdersScreen.routeName: (ctx) => const OrdersScreen(),
                  UserProductsScreen.routeName: (ctx) =>
                      const UserProductsScreen(),
                },
                onGenerateRoute: (settings) {
                  if (settings.name == EditProductScreen.routeName) {
                    final productId = settings.arguments as String?;
                    return MaterialPageRoute(
                      builder: (ctx) {
                        return EditProductScreen(
                          productId != null
                              ? ctx.read<ProductsManager>().findById(productId)
                              : null,
                        );
                      },
                    );
                  }
                  return null;
                });
          },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
