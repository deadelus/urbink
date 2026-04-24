import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';


/// Écran de politique de confidentialité — affiché au premier lancement.
///
/// L'utilisateur doit accepter pour accéder à l'app (FR45, RGPD).
/// À l'acceptation :
///   1. Persiste le consentement dans SharedPreferences
///   2. Crée un compte Firebase Anonymous Auth (FR32)
///   3. Notifie [privacyNotifier] → GoRouter redirige vers /map
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _loading = false;

  Future<void> _onAccept() async {
    setState(() => _loading = true);
    try {
      // 1. Persister le consentement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kPrivacyAcceptedKey, true);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // 2. Connexion Firebase anonyme en arrière-plan — non bloquante.
    // currentUidProvider utilise localAnonUid si Firebase est indisponible ;
    // la reconnexion est retentée via connectivityChangesProvider.
    if (FirebaseAuth.instance.currentUser == null) {
      // ignore: unawaited_futures
      FirebaseAuth.instance.signInAnonymously().ignore();
    }

    // 3. Naviguer immédiatement — pas besoin d'attendre Firebase
    privacyNotifier.setAccepted();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: UrbinkColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UrbinkSpacing.lg,
            vertical: UrbinkSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Logo / titre
              Text(
                'Urbink',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: UrbinkColors.accent,
                      fontFamily: 'CrimsonPro',
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: UrbinkSpacing.sm),
              Text(
                l10n.app_tagline,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: UrbinkColors.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: UrbinkSpacing.xl * 2),
              // Politique de confidentialité
              _PrivacySection(
                icon: Icons.location_on_outlined,
                title: l10n.privacy_gps_title,
                body: l10n.privacy_gps_body,
              ),
              const SizedBox(height: UrbinkSpacing.lg),
              _PrivacySection(
                icon: Icons.lock_outline,
                title: l10n.privacy_anon_title,
                body: l10n.privacy_anon_body,
              ),
              const SizedBox(height: UrbinkSpacing.lg),
              _PrivacySection(
                icon: Icons.map_outlined,
                title: l10n.privacy_maps_title,
                body: l10n.privacy_maps_body,
              ),
              const Spacer(),
              // Bouton accepter
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: UrbinkColors.secondary,
                    minimumSize:
                        const Size(double.infinity, UrbinkSpacing.minTapTarget),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(UrbinkSpacing.radiusButton),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.btn_accept_continue,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: UrbinkSpacing.md),
              Center(
                child: Text(
                  l10n.privacy_footer,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: UrbinkColors.onSurface.withValues(alpha: 0.5),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: UrbinkColors.accent, size: 24),
        const SizedBox(width: UrbinkSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: UrbinkColors.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: UrbinkColors.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
