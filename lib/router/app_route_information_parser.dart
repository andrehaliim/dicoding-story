import 'package:flutter/material.dart';
import 'package:story/router/app_route_path.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.uri.toString());
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return const SplashRoutePath();
    }

    switch (pathSegments[0]) {
      case 'login':
        return const LoginRoutePath();
      case 'register':
        return const RegisterRoutePath();
      case 'home':
        return const HomeRoutePath();
      case 'upload':
        return const UploadRoutePath();
      case 'detail':
        if (pathSegments.length >= 2) {
          return DetailRoutePath(pathSegments[1]);
        }
        return const HomeRoutePath();
      default:
        return const SplashRoutePath();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    if (configuration is SplashRoutePath) {
      return RouteInformation(uri: Uri.parse('/'));
    }
    if (configuration is LoginRoutePath) {
      return RouteInformation(uri: Uri.parse('/login'));
    }
    if (configuration is RegisterRoutePath) {
      return RouteInformation(uri: Uri.parse('/register'));
    }
    if (configuration is HomeRoutePath) {
      return RouteInformation(uri: Uri.parse('/home'));
    }
    if (configuration is UploadRoutePath) {
      return RouteInformation(uri: Uri.parse('/upload'));
    }
    if (configuration is DetailRoutePath) {
      return RouteInformation(uri: Uri.parse('/detail/${configuration.storyId}'));
    }
    return null;
  }
}
