import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Titre section couches carte
  ///
  /// In fr, this message translates to:
  /// **'Affichage carte'**
  String get layers_title;

  /// Label couche monuments
  ///
  /// In fr, this message translates to:
  /// **'Monuments visités'**
  String get layer_monuments;

  /// Sous-label couche monuments
  ///
  /// In fr, this message translates to:
  /// **'POIs officiels sur la carte'**
  String get layer_monuments_sub;

  /// Label couche quartiers
  ///
  /// In fr, this message translates to:
  /// **'Délimitations quartiers'**
  String get layer_quartiers;

  /// Sous-label couche quartiers
  ///
  /// In fr, this message translates to:
  /// **'Zones de la ville'**
  String get layer_quartiers_sub;

  /// Label couche photos
  ///
  /// In fr, this message translates to:
  /// **'Photos épinglées'**
  String get layer_photos;

  /// Sous-label couche photos
  ///
  /// In fr, this message translates to:
  /// **'Découvertes communautaires'**
  String get layer_photos_sub;

  /// Bouton fermer
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get btn_close;

  /// Bouton retour
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get btn_back;

  /// Bouton créer
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get btn_create;

  /// Bouton annuler
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get btn_cancel;

  /// Bouton abandonner session
  ///
  /// In fr, this message translates to:
  /// **'Abandonner'**
  String get btn_discard;

  /// Bouton reprendre session
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get btn_resume;

  /// Titre / hint collapsed bottom sheet
  ///
  /// In fr, this message translates to:
  /// **'Démarrer une sortie'**
  String get exit_start_session;

  /// CTA bouton démarrer la sortie
  ///
  /// In fr, this message translates to:
  /// **'Démarrer la sortie'**
  String get exit_start_session_cta;

  /// Mode de sortie sans itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Circuit libre'**
  String get mode_free_circuit;

  /// Sous-label mode circuit libre
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get mode_free_default;

  /// Mode de sortie avec itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get mode_itinerary;

  /// Sous-label CTA choisir un itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Choisir →'**
  String get mode_itinerary_choose;

  /// Chip GPS prêt dans le sheet
  ///
  /// In fr, this message translates to:
  /// **'Mode auto-détecté · GPS prêt'**
  String get gps_mode_ready;

  /// Titre section choix app de navigation
  ///
  /// In fr, this message translates to:
  /// **'Naviguer avec…'**
  String get navigate_with_title;

  /// CTA démarrer navigation
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get btn_lets_go;

  /// Titre liste des itinéraires
  ///
  /// In fr, this message translates to:
  /// **'Mes itinéraires'**
  String get my_itineraries;

  /// Option navigation GPS intégré
  ///
  /// In fr, this message translates to:
  /// **'GPS intégré'**
  String get nav_gps_integrated;

  /// Sous-label GPS intégré
  ///
  /// In fr, this message translates to:
  /// **'Recommandé'**
  String get nav_gps_recommended;

  /// Option navigation Apple Plans
  ///
  /// In fr, this message translates to:
  /// **'Apple Plans'**
  String get nav_apple_plans;

  /// Sous-label Apple Plans
  ///
  /// In fr, this message translates to:
  /// **'Application Maps'**
  String get nav_apple_maps_app;

  /// Option navigation Google Maps
  ///
  /// In fr, this message translates to:
  /// **'Google Maps'**
  String get nav_google_maps;

  /// Sous-label Google Maps
  ///
  /// In fr, this message translates to:
  /// **'Application externe'**
  String get nav_external_app;

  /// Option navigation Waze
  ///
  /// In fr, this message translates to:
  /// **'Waze'**
  String get nav_waze;

  /// Sous-label Waze
  ///
  /// In fr, this message translates to:
  /// **'Voiture uniquement'**
  String get nav_car_only;

  /// Label collapsed sheet itinéraire sans étapes
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des étapes'**
  String get add_steps;

  /// Pluriel étapes pour le label collapsed
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} étape} other{{count} étapes}}'**
  String step_count(int count);

  /// Onglet mode manuel itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Manuel'**
  String get tab_manual;

  /// Onglet mode auto-génération itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Auto ✨'**
  String get tab_auto;

  /// Titre liste étapes itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Étapes du parcours'**
  String get steps_title;

  /// Badge compteur étapes avec minimum
  ///
  /// In fr, this message translates to:
  /// **'{count} / min. 3'**
  String step_counter_badge(int count);

  /// Placeholder champ nom itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Nommer cet itinéraire… (optionnel)'**
  String get itinerary_name_hint;

  /// Titre état vide itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Aucune étape pour l\'instant'**
  String get empty_no_steps;

  /// Sous-titre état vide itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne des lieux sur la carte'**
  String get empty_select_places;

  /// Bouton créer itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'itinéraire'**
  String get btn_create_itinerary;

  /// Message chargement génération itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Génération en cours…'**
  String get generating_loading;

  /// Titre section génération automatique
  ///
  /// In fr, this message translates to:
  /// **'Génération automatique'**
  String get auto_gen_title;

  /// Description génération automatique
  ///
  /// In fr, this message translates to:
  /// **'Maximise les rues non explorées autour de toi'**
  String get auto_gen_description;

  /// Unité durée en minutes
  ///
  /// In fr, this message translates to:
  /// **'min'**
  String get time_unit_minutes;

  /// Bouton générer itinéraire auto
  ///
  /// In fr, this message translates to:
  /// **'Générer l\'itinéraire'**
  String get btn_generate_itinerary;

  /// Bouton regénérer itinéraire
  ///
  /// In fr, this message translates to:
  /// **'Regénérer'**
  String get btn_regenerate;

  /// Bouton utiliser itinéraire généré
  ///
  /// In fr, this message translates to:
  /// **'Utiliser cet itinéraire'**
  String get btn_use_itinerary;

  /// SnackBar mode hors-ligne
  ///
  /// In fr, this message translates to:
  /// **'Mode hors-ligne — carte limitée au cache'**
  String get offline_mode_message;

  /// Titre dialog crash recovery
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la session précédente ?'**
  String get resume_session_title;

  /// Message dialog session interrompue
  ///
  /// In fr, this message translates to:
  /// **'Une session a été interrompue. Tu peux la reprendre ou l\'abandonner.'**
  String get session_interrupted_message;

  /// Message erreur chargement style carte
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le style de la carte.'**
  String get error_map_style;

  /// Placeholder barre de recherche
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un lieu…'**
  String get search_placeholder;

  /// Titre écran filtres
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filters_title;

  /// Bouton réinitialiser tous les filtres
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get btn_reset_filters;

  /// Bandeau compteur filtres actifs
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} filtre actif} other{{count} filtres actifs}}'**
  String active_filter_count(int count);

  /// Titre écran résumé session
  ///
  /// In fr, this message translates to:
  /// **'Sortie terminée'**
  String get session_completed;

  /// Label stat rues explorées
  ///
  /// In fr, this message translates to:
  /// **'Rues explorées'**
  String get stat_streets;

  /// Label stat distance
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get stat_distance;

  /// Label stat durée
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get stat_duration;

  /// Label stat mode déplacement
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get stat_mode;

  /// Bouton retour carte depuis résumé session
  ///
  /// In fr, this message translates to:
  /// **'Retour à la carte'**
  String get btn_back_to_map;

  /// Titre dialog GPS requis
  ///
  /// In fr, this message translates to:
  /// **'GPS requis'**
  String get gps_required_title;

  /// Message dialog GPS requis
  ///
  /// In fr, this message translates to:
  /// **'Le GPS est requis pour colorier tes rues.\nActive-le dans les Réglages pour continuer.'**
  String get gps_required_message;

  /// Bouton ouvrir paramètres système
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get btn_open_settings;

  /// Bouton voir plus de filtres
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get btn_see_more;

  /// Label pill zones — inactif
  ///
  /// In fr, this message translates to:
  /// **'Voir les zones explorées'**
  String get zones_show;

  /// Label pill zones — actif
  ///
  /// In fr, this message translates to:
  /// **'Cacher les zones explorées'**
  String get zones_hide;

  /// Onglet navigation Carte
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get tab_map;

  /// Onglet navigation Parcours
  ///
  /// In fr, this message translates to:
  /// **'Parcours'**
  String get tab_itineraries;

  /// Onglet navigation Social
  ///
  /// In fr, this message translates to:
  /// **'Social'**
  String get tab_social;

  /// Onglet navigation Badges
  ///
  /// In fr, this message translates to:
  /// **'Badges'**
  String get tab_badges;

  /// Onglet navigation Profil
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tab_profile;

  /// Label Semantics onglet de navigation
  ///
  /// In fr, this message translates to:
  /// **'{name}, onglet {index} sur {total}'**
  String nav_tab_semantics(String name, int index, int total);

  /// Texte pill session counter (rues, distance, temps)
  ///
  /// In fr, this message translates to:
  /// **'{streets} rues · {distance} · {time}'**
  String session_counter_text(int streets, String distance, String time);

  /// Texte principal barre de statut session
  ///
  /// In fr, this message translates to:
  /// **'Circuit libre · {streets} rues · {distance}'**
  String session_status_text(int streets, String distance);

  /// Label Semantics barre de statut session
  ///
  /// In fr, this message translates to:
  /// **'Session en cours : {streets} rues, {distance}, {time}'**
  String session_status_semantics(int streets, String distance, String time);

  /// Tagline de l'application (intentionnellement en anglais)
  ///
  /// In fr, this message translates to:
  /// **'Every detour hides a discovery.'**
  String get app_tagline;

  /// Titre section confidentialité GPS
  ///
  /// In fr, this message translates to:
  /// **'Localisation GPS'**
  String get privacy_gps_title;

  /// Corps section confidentialité GPS
  ///
  /// In fr, this message translates to:
  /// **'Urbink utilise ton GPS pour colorier les rues que tu parcours en temps réel pendant une session active. Le tracking s\'arrête lorsque la session est mise en pause ou stoppée.'**
  String get privacy_gps_body;

  /// Titre section confidentialité compte anonyme
  ///
  /// In fr, this message translates to:
  /// **'Compte anonyme'**
  String get privacy_anon_title;

  /// Corps section confidentialité compte anonyme
  ///
  /// In fr, this message translates to:
  /// **'Ta progression est sauvegardée sous un identifiant anonyme. Aucune donnée personnelle n\'est requise pour utiliser Urbink.'**
  String get privacy_anon_body;

  /// Titre section confidentialité cartes
  ///
  /// In fr, this message translates to:
  /// **'Données cartographiques'**
  String get privacy_maps_title;

  /// Corps section confidentialité cartes
  ///
  /// In fr, this message translates to:
  /// **'© OpenStreetMap contributors — données cartographiques sous licence ODbL.'**
  String get privacy_maps_body;

  /// Bouton accepter politique de confidentialité
  ///
  /// In fr, this message translates to:
  /// **'Accepter et continuer'**
  String get btn_accept_continue;

  /// Avertissement acceptation confidentialité
  ///
  /// In fr, this message translates to:
  /// **'En continuant, tu acceptes notre politique de confidentialité.'**
  String get privacy_footer;

  /// Label live indicator session active
  ///
  /// In fr, this message translates to:
  /// **'Sortie en cours'**
  String get session_live;

  /// Label durée dans le moniteur de session
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get session_duration;

  /// Label nombre de rues — stat card session monitor
  ///
  /// In fr, this message translates to:
  /// **'Rues'**
  String get streets;

  /// Label allure — stat card session monitor
  ///
  /// In fr, this message translates to:
  /// **'Allure'**
  String get pace;

  /// CTA arrêter la sortie (session monitor)
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la sortie'**
  String get btn_stop;

  /// Titre section progression session en direct
  ///
  /// In fr, this message translates to:
  /// **'Progression en direct'**
  String get live_progress;

  /// Label zone explorée dans la section progression
  ///
  /// In fr, this message translates to:
  /// **'Zone explorée'**
  String get zone_progress;

  /// Label nouvelles rues dans la section progression
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles rues'**
  String get new_streets;

  /// Label calories dans la section progression
  ///
  /// In fr, this message translates to:
  /// **'Calories'**
  String get calories;

  /// Titre carte astuce contextuelle
  ///
  /// In fr, this message translates to:
  /// **'Astuce'**
  String get tip_title;

  /// Label mode libre dans le header session monitor
  ///
  /// In fr, this message translates to:
  /// **'Libre'**
  String get mode_libre;

  /// Titre bottom sheet résumé de sortie
  ///
  /// In fr, this message translates to:
  /// **'Sortie terminée !'**
  String get sum_title;

  /// Sous-titre encouragement résumé de sortie
  ///
  /// In fr, this message translates to:
  /// **'Belle exploration, continuez comme ça'**
  String get sum_sub;

  /// Unité stat rues explorées (résumé)
  ///
  /// In fr, this message translates to:
  /// **'rues explorées'**
  String get sum_streets;

  /// Unité stat distance en km (résumé)
  ///
  /// In fr, this message translates to:
  /// **'kilomètres'**
  String get sum_km;

  /// Unité stat durée (résumé)
  ///
  /// In fr, this message translates to:
  /// **'durée'**
  String get sum_duration;

  /// Unité stat nouveaux badges (résumé)
  ///
  /// In fr, this message translates to:
  /// **'nouveaux badges'**
  String get sum_new_badges;

  /// Bandeau badges débloqués avec pluralisation
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{} one{{count} badge débloqué !} other{{count} badges débloqués !}}'**
  String sum_badges_unlocked(int count);

  /// Bouton partager résumé de sortie
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get sum_share;

  /// Bouton principal fermer résumé de sortie
  ///
  /// In fr, this message translates to:
  /// **'Super !'**
  String get sum_done;

  /// Titre overlay célébration badge
  ///
  /// In fr, this message translates to:
  /// **'Badge débloqué !'**
  String get celeb_title;

  /// Bouton principal overlay célébration badge
  ///
  /// In fr, this message translates to:
  /// **'Continuer l\'exploration'**
  String get celeb_continue;

  /// Lien ignorer célébration badge
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get celeb_skip;

  /// Indicateur de progression badge (ex : 2 / 3)
  ///
  /// In fr, this message translates to:
  /// **'{current} / {total}'**
  String celeb_progress(int current, int total);

  /// Titre de l'onglet Vous (historique personnel)
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get profile_title;

  /// Titre section liste — aucun filtre jour
  ///
  /// In fr, this message translates to:
  /// **'Toutes les sorties'**
  String get profile_all_sessions;

  /// Titre section liste — filtrée par jour
  ///
  /// In fr, this message translates to:
  /// **'Sorties du {day}'**
  String profile_sessions_of(String day);

  /// Message d'erreur liste sorties
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get profile_error_loading;

  /// Empty state liste — aucune sortie globale
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de sortie — explore ta ville !'**
  String get profile_no_sessions;

  /// Empty state liste — aucune sortie ce jour
  ///
  /// In fr, this message translates to:
  /// **'Aucune sortie ce jour-là'**
  String get profile_no_sessions_day;

  /// Footer pagination — toutes les sorties chargées
  ///
  /// In fr, this message translates to:
  /// **'Tout affiché'**
  String get profile_all_shown;

  /// Label toggle vue simple
  ///
  /// In fr, this message translates to:
  /// **'Simple'**
  String get profile_view_simple;

  /// Label toggle vue feed
  ///
  /// In fr, this message translates to:
  /// **'Feed'**
  String get profile_view_feed;

  /// Placeholder vue feed (à venir)
  ///
  /// In fr, this message translates to:
  /// **'Vue feed disponible à l\'Epic 9'**
  String get profile_feed_placeholder;

  /// Message empty state histogramme hebdomadaire
  ///
  /// In fr, this message translates to:
  /// **'Ta première sortie cette semaine n\'attend que toi'**
  String get histogram_empty_message;

  /// CTA empty state histogramme — démarrer une sortie
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get histogram_start_cta;

  /// Titre section badges quartiers débloqués dans l'écran Challenges
  ///
  /// In fr, this message translates to:
  /// **'Badges Quartiers'**
  String get challenges_badges_section_title;

  /// Titre overlay célébration quartier complété
  ///
  /// In fr, this message translates to:
  /// **'🏆 Quartier {name} complété !'**
  String celeb_district_title(String name);

  /// Label section secret local dans l'overlay quartier
  ///
  /// In fr, this message translates to:
  /// **'Secret local'**
  String get celeb_secret_local_label;

  /// Bouton partager overlay quartier
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get celeb_share;

  /// Label Semantics VoiceOver overlay quartier complété
  ///
  /// In fr, this message translates to:
  /// **'Badge quartier {name} débloqué. Secret local révélé.'**
  String celeb_district_semantics(String name);

  /// Sous-titre intro collections sur BadgesScreen
  ///
  /// In fr, this message translates to:
  /// **'Explorez Paris par thématique'**
  String get badges_collections_intro;

  /// Label collection 100% débloquée
  ///
  /// In fr, this message translates to:
  /// **'Collection complète !'**
  String get badges_collection_complete;

  /// Sous-titre collection complète
  ///
  /// In fr, this message translates to:
  /// **'Vous avez débloqué tous les monuments'**
  String get badges_collection_complete_sub;

  /// Label stat collections dans le stats banner de BadgesScreen
  ///
  /// In fr, this message translates to:
  /// **'Collections'**
  String get badges_stat_collections;

  /// Bouton partager — monument detail sheet
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get btn_share;

  /// Bouton voir sur la carte — monument detail sheet
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get btn_show_on_map;

  /// Titre status card monument visité
  ///
  /// In fr, this message translates to:
  /// **'Badge débloqué'**
  String get mon_visited;

  /// Sous-titre status card monument visité
  ///
  /// In fr, this message translates to:
  /// **'Monument visité lors d\'une sortie Urbink'**
  String get mon_visited_sub;

  /// Titre status card monument verrouillé
  ///
  /// In fr, this message translates to:
  /// **'Pas encore visité'**
  String get mon_locked;

  /// Sous-titre status card monument verrouillé
  ///
  /// In fr, this message translates to:
  /// **'Approchez-vous à moins de 100 m pour débloquer'**
  String get mon_locked_sub;

  /// Label arrondissement — monument detail sheet
  ///
  /// In fr, this message translates to:
  /// **'{n} arr.'**
  String mon_arr(String n);

  /// Titre section badges monuments dans l'écran Challenges
  ///
  /// In fr, this message translates to:
  /// **'Monuments'**
  String get challenges_monuments_section_title;

  /// Chip badge récemment débloqué dans la grille
  ///
  /// In fr, this message translates to:
  /// **'Nouveau !'**
  String get badge_new;

  /// Hint dans la sheet badge verrouillé
  ///
  /// In fr, this message translates to:
  /// **'Passe à {radius} m pour débloquer ce badge.'**
  String badge_locked_hint(String radius);

  /// Label onglet Objectifs thématiques dans BadgesScreen
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get tab_objectifs;

  /// Bouton activation d'un objectif thématique
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get objectif_activate;

  /// Bouton désactivation d'un objectif thématique (état actif)
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get objectif_deactivate;

  /// Label objectif thématique complété à 100%
  ///
  /// In fr, this message translates to:
  /// **'Complété'**
  String get objectif_complete;

  /// Mode de déplacement à pied
  ///
  /// In fr, this message translates to:
  /// **'À pied'**
  String get transport_foot;

  /// Mode de déplacement à vélo
  ///
  /// In fr, this message translates to:
  /// **'Vélo'**
  String get transport_bike;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
