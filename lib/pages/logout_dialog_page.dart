import 'package:flutter/material.dart';
import 'package:story/l10n/app_localizations.dart';
import 'package:story/proxys/login_proxy.dart';

class LogoutDialogPage extends Page {
  final Function() onLogout;
  final Function() onCancel;

  const LogoutDialogPage({
    required this.onLogout,
    required this.onCancel,
    super.key,
    super.name,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      opaque: false,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _LogoutDialogWidget(onLogout: onLogout, onCancel: onCancel),
    );
  }
}

class _LogoutDialogWidget extends StatelessWidget {
  final Function() onLogout;
  final Function() onCancel;

  const _LogoutDialogWidget({required this.onLogout, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirm),
          actions: [
            TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
            TextButton(
              onPressed: () async {
                final proxy = LoginProxy();
                await proxy.doLogout();
                onLogout();
              },
              child: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}
