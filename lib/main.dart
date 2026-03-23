import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final transactionProvider = TransactionProvider();
  final budgetProvider = BudgetProvider();
  final categoryProvider = CategoryProvider();
  final themeProvider = ThemeProvider();
  final profileProvider = ProfileProvider();

  await transactionProvider.loadTransactions();
  await budgetProvider.loadBudgets();
  await categoryProvider.loadCategories();
  await themeProvider.loadTheme();
  await profileProvider.loadProfile();

  await budgetProvider.syncSpentFromTransactions(
    transactionProvider.transactions,
  );

  runApp(
    MyApp(
      transactionProvider: transactionProvider,
      budgetProvider: budgetProvider,
      categoryProvider: categoryProvider,
      themeProvider: themeProvider,
      profileProvider: profileProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final TransactionProvider transactionProvider;
  final BudgetProvider budgetProvider;
  final CategoryProvider categoryProvider;
  final ThemeProvider themeProvider;
  final ProfileProvider profileProvider;

  const MyApp({
    super.key,
    required this.transactionProvider,
    required this.budgetProvider,
    required this.categoryProvider,
    required this.themeProvider,
    required this.profileProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionProvider>.value(
          value: transactionProvider,
        ),
        ChangeNotifierProvider<BudgetProvider>.value(value: budgetProvider),
        ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Quản lý tài chính cá nhân',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
