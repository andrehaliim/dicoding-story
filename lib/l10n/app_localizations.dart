import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('id')];

  bool get _isId => locale.languageCode == 'id';

  String get appTitle => _isId ? 'Cerita' : 'Story';
  String get story => _isId ? 'Cerita' : 'Story';

  String get logout => _isId ? 'Keluar' : 'Logout';
  String get logoutConfirm => _isId
      ? 'Apakah kamu yakin ingin keluar?'
      : 'Are you sure you want to logout?';
  String get cancel => _isId ? 'Batal' : 'Cancel';
  String get noStories => _isId ? 'Tidak ada cerita' : 'No stories found';
  String get switchLanguage => _isId ? 'Ganti Bahasa' : 'Switch Language';

  String get welcomeTo => _isId
      ? 'Selamat datang di\nDicoding Story'
      : 'Welcome to\nDicoding Story';
  String get email => _isId ? 'Email' : 'Email';
  String get password => _isId ? 'Kata Sandi' : 'Password';
  String get enterEmail =>
      _isId ? 'Mohon masukkan email Anda' : 'Please enter your email';
  String get validEmail =>
      _isId ? 'Mohon masukkan email yang valid' : 'Please enter a valid email';
  String get enterPassword =>
      _isId ? 'Mohon masukkan kata sandi Anda' : 'Please enter your password';
  String get passwordLength => _isId
      ? 'Kata sandi harus minimal 8 karakter'
      : 'Password must be at least 8 characters';
  String get login => _isId ? 'Masuk' : 'Login';
  String get noAccount =>
      _isId ? 'Belum punya akun?' : "Don't have an account?";
  String get register => _isId ? 'Daftar' : 'Register';

  String get createAccount => _isId ? 'Buat Akun' : 'Create Account';
  String get name => _isId ? 'Nama' : 'Name';
  String get enterName =>
      _isId ? 'Mohon masukkan nama Anda' : 'Please enter your name';
  String get alreadyAccount =>
      _isId ? 'Sudah punya akun?' : 'Already have an account?';
  String get registrationFailed =>
      _isId ? 'Pendaftaran gagal' : 'Registration failed';
  String get registrationSuccess =>
      _isId ? 'Pendaftaran berhasil' : 'Registration success';

  String get uploadStory => _isId ? 'Unggah Cerita' : 'Upload Story';
  String get camera => _isId ? 'Kamera' : 'Camera';
  String get gallery => _isId ? 'Galeri' : 'Gallery';
  String get description => _isId ? 'Deskripsi' : 'Description';
  String get descriptionHint => _isId
      ? 'Masukkan deskripsi ceritamu...'
      : 'Enter your story description...';
  String get selectImage => _isId
      ? 'Mohon pilih gambar terlebih dahulu'
      : 'Please select an image first';
  String get enterDescription =>
      _isId ? 'Mohon masukkan deskripsi' : 'Please enter a description';
  String get uploadSuccess =>
      _isId ? 'Cerita berhasil diunggah!' : 'Story uploaded successfully!';
  String get upload => _isId ? 'Unggah' : 'Upload';
  String failedPickImage(String error) =>
      _isId ? 'Gagal memilih gambar: $error' : 'Failed to pick image: $error';
  String uploadFailed(String error) =>
      _isId ? 'Gagal mengunggah: $error' : 'Upload failed: $error';

  String get detailStory => _isId ? 'Detail Cerita' : 'Detail Story';
  String get loadingLocation =>
      _isId ? 'Memuat lokasi...' : 'Loading location...';
  String get locationNotAvailable =>
      _isId ? 'Lokasi tidak tersedia' : 'Location not available';
  String get locationNotSelected =>
      _isId ? 'Lokasi belum dipilih' : 'Location not selected';
  String unknownLocation(double lat, double lon) => _isId
      ? 'Lokasi tidak diketahui ($lat, $lon)'
      : 'Unknown location ($lat, $lon)';

  String get location => _isId ? 'Lokasi' : 'Location';
  String get pickLocation => _isId ? 'Pilih Lokasi' : 'Pick Location';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .map((l) => l.languageCode)
      .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
