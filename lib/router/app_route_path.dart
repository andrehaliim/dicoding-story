/// Represents all possible navigation destinations in the app.
abstract class AppRoutePath {
  const AppRoutePath();
}

class SplashRoutePath extends AppRoutePath {
  const SplashRoutePath();
}

class LoginRoutePath extends AppRoutePath {
  const LoginRoutePath();
}

class RegisterRoutePath extends AppRoutePath {
  const RegisterRoutePath();
}

class HomeRoutePath extends AppRoutePath {
  const HomeRoutePath();
}

class DetailRoutePath extends AppRoutePath {
  final String storyId;
  const DetailRoutePath(this.storyId);
}

class UploadRoutePath extends AppRoutePath {
  const UploadRoutePath();
}
