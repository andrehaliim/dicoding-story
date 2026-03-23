import 'package:flutter/material.dart';
import 'package:story/models/story-model.dart';
import 'package:story/pages/detail-page.dart';
import 'package:story/pages/home-page.dart';
import 'package:story/pages/login-page.dart';
import 'package:story/pages/register-page.dart';
import 'package:story/proxys/login-proxy.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  List<Page> pageStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  StoryModel? selectedStory;

  MyRouterDelegate() : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  Future<void> _init() async {
    isLoggedIn = await LoginProxy().isLoggedIn();
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      pageStack = _loadingStack;
    } else if (isLoggedIn == true) {
      pageStack = _loggedInStack;
    } else {
      pageStack = _loggedOutStack;
    }

    return Navigator(
      key: navigatorKey,
      pages: pageStack,
      onDidRemovePage: (page) {
        if (page.key == ValueKey(selectedStory)) {
          selectedStory = null;
          notifyListeners();
        }
        if (page.key == const ValueKey("RegisterPage")) {
          isRegister = false;
          notifyListeners();
        }
      },
    );
  }

  @override
  Future<void> setNewRoutePath(dynamic configuration) {
    // TODO: implement setNewRoutePath
    throw UnimplementedError();
  }

  List<Page> get _loadingStack => const [
    MaterialPage(
      key: ValueKey("LoadingPage"),
      child: Center(child: CircularProgressIndicator()),
    ),
  ];

  List<Page> get _loggedOutStack => [
    MaterialPage(
      key: const ValueKey("LoginPage"),
      child: LoginPage(
        onLogin: () {
          isLoggedIn = true;
          notifyListeners();
        },
        onRegister: () {
          isRegister = true;
          notifyListeners();
        },
      ),
    ),
    if (isRegister == true)
      MaterialPage(
        key: const ValueKey("RegisterPage"),
        child: RegisterPage(
          onRegister: () {
            isRegister = false;
            notifyListeners();
          },
          onLogin: () {
            isRegister = false;
            notifyListeners();
          },
        ),
      ),
  ];

  List<Page> get _loggedInStack => [
    MaterialPage(
      key: const ValueKey("QuotesListPage"),
      child: HomePage(
        onTapped: (StoryModel story) {
          selectedStory = story;
          notifyListeners();
        },
        onLogout: () {
          isLoggedIn = false;
          notifyListeners();
        },
      ),
    ),
    if (selectedStory != null)
      MaterialPage(
        key: ValueKey(selectedStory),
        child: DetailPage(story: selectedStory!),
      ),
  ];
}
