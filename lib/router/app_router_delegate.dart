import 'package:flutter/material.dart';
import 'package:story/models/story-model.dart';
import 'package:story/pages/detail-page.dart';
import 'package:story/pages/home-page.dart';
import 'package:story/pages/login-page.dart';
import 'package:story/pages/register-page.dart';
import 'package:story/pages/upload-page.dart';
import 'package:story/proxys/login-proxy.dart';
import 'package:story/router/app_route_path.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // ---------------------------------------------------------------------------
  // Navigation state
  // ---------------------------------------------------------------------------
  bool? _isLoggedIn;
  bool _showRegister = false;
  bool _showUpload = false;
  StoryModel? _selectedStory;

  // ---------------------------------------------------------------------------
  // Constructor: check auth on startup
  // ---------------------------------------------------------------------------
  AppRouterDelegate() {
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await LoginProxy().isLoggedIn();
    _isLoggedIn = loggedIn;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // currentConfiguration — used by RouteInformationParser to restore URLs
  // ---------------------------------------------------------------------------
  @override
  AppRoutePath get currentConfiguration {
    if (_isLoggedIn == null) return const SplashRoutePath();
    if (!_isLoggedIn!) {
      if (_showRegister) return const RegisterRoutePath();
      return const LoginRoutePath();
    }
    if (_selectedStory != null) return DetailRoutePath(_selectedStory!.id);
    if (_showUpload) return const UploadRoutePath();
    return const HomeRoutePath();
  }

  // ---------------------------------------------------------------------------
  // setNewRoutePath — called when the OS / browser provides a deep-link URL
  // ---------------------------------------------------------------------------
  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    if (configuration is LoginRoutePath) {
      _isLoggedIn = false;
      _showRegister = false;
    } else if (configuration is RegisterRoutePath) {
      _isLoggedIn = false;
      _showRegister = true;
    } else if (configuration is HomeRoutePath) {
      _isLoggedIn = true;
      _showUpload = false;
      _selectedStory = null;
    } else if (configuration is UploadRoutePath) {
      _isLoggedIn = true;
      _showUpload = true;
      _selectedStory = null;
    } else if (configuration is DetailRoutePath) {
      _isLoggedIn = true;
      // We can't rehydrate the full StoryModel from URL alone on mobile,
      // so fall back to Home if the story isn't already loaded.
      if (_selectedStory?.id != configuration.storyId) {
        _selectedStory = null;
      }
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Navigation callbacks (called by pages instead of Navigator.push/pop)
  // ---------------------------------------------------------------------------
  void goToRegister() {
    _showRegister = true;
    notifyListeners();
  }

  void goToLogin() {
    _showRegister = false;
    _isLoggedIn = false;
    notifyListeners();
  }

  void onLoginSuccess() {
    _isLoggedIn = true;
    _showRegister = false;
    notifyListeners();
  }

  void onLogoutSuccess() {
    _isLoggedIn = false;
    _showUpload = false;
    _selectedStory = null;
    notifyListeners();
  }

  void goToDetail(StoryModel story) {
    _selectedStory = story;
    notifyListeners();
  }

  void goToUpload() {
    _showUpload = true;
    notifyListeners();
  }

  void goBack() {
    if (_selectedStory != null) {
      _selectedStory = null;
    } else if (_showUpload) {
      _showUpload = false;
    } else if (_showRegister) {
      _showRegister = false;
    }
    notifyListeners();
  }

  void onUploadSuccess() {
    _showUpload = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // build — the declarative page stack
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Still checking auth
    if (_isLoggedIn == null) {
      return Navigator(
        key: navigatorKey,
        pages: const [
          MaterialPage(
            key: ValueKey('splash'),
            child: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
        onDidRemovePage: (page) {},
      );
    }

    return Navigator(
      key: navigatorKey,
      pages: [
        // ── Auth flow ──────────────────────────────────────────────────────
        if (!_isLoggedIn!) ...[
          MaterialPage(
            key: const ValueKey('login'),
            child: LoginPage(
              onLoginSuccess: onLoginSuccess,
              onGoToRegister: goToRegister,
            ),
          ),
          if (_showRegister)
            MaterialPage(
              key: const ValueKey('register'),
              child: RegisterPage(
                onRegisterSuccess: goToLogin,
                onGoToLogin: goToLogin,
              ),
            ),
        ],

        // ── Main app flow ──────────────────────────────────────────────────
        if (_isLoggedIn!) ...[
          MaterialPage(
            key: const ValueKey('home'),
            child: HomePage(
              onGoToDetail: goToDetail,
              onGoToUpload: goToUpload,
              onLogout: onLogoutSuccess,
            ),
          ),
          if (_showUpload)
            MaterialPage(
              key: const ValueKey('upload'),
              child: UploadPage(
                onUploadSuccess: onUploadSuccess,
                onBack: goBack,
              ),
            ),
          if (_selectedStory != null)
            MaterialPage(
              key: ValueKey('detail-${_selectedStory!.id}'),
              child: DetailPage(
                story: _selectedStory!,
                onBack: goBack,
              ),
            ),
        ],
      ],
      onDidRemovePage: (page) {
        // Handle system back gestures / back button
        goBack();
      },
    );
  }
}
