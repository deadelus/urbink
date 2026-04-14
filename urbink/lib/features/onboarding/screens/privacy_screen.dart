import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

const _kPrivacyKey = 'urbink_privacy_accepted';

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
      await prefs.setBool(_kPrivacyKey, true);

      // 2. Auth anonyme si pas encore connecté
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      // 3. Notifier GoRouter → redirect automatique vers /map
      privacyNotifier.setAccepted();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      color: UrbinkColors.ocre,
                      fontFamily: 'CrimsonPro',
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: UrbinkSpacing.sm),
              Text(
                'Every detour hides a discovery.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: UrbinkColors.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: UrbinkSpacing.xl * 2),
              // Politique de confidentialité
              const _PrivacySection(
                icon: Icons.location_on_outlined,
                title: 'Localisation GPS',
                body:
                    'Urbink utilise ton GPS pour colorier les rues que tu parcours en temps réel. '
                    'Le tracking s\'arrête dès que tu fermes l\'app.',
              ),
              const SizedBox(height: UrbinkSpacing.lg),
              const _PrivacySection(
                icon: Icons.lock_outline,
                title: 'Compte anonyme',
                body:
                    'Ta progression est sauvegardée sous un identifiant anonyme. '
                    'Aucune donnée personnelle n\'est requise pour utiliser Urbink.',
              ),
              const SizedBox(height: UrbinkSpacing.lg),
              const _PrivacySection(
                icon: Icons.map_outlined,
                title: 'Données cartographiques',
                body: '© OpenStreetMap contributors — données cartographiques '
                    'sous licence ODbL.',
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
                      : const Text(
                          'Accepter et continuer',
                          style: TextStyle(
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
                  'En continuant, tu acceptes notre politique de confidentialité.',
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
        Icon(icon, color: UrbinkColors.ocre, size: 24),
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
