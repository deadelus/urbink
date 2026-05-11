// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get layers_title => 'Affichage carte';

  @override
  String get layer_monuments => 'Monuments visités';

  @override
  String get layer_monuments_sub => 'POIs officiels sur la carte';

  @override
  String get layer_quartiers => 'Délimitations quartiers';

  @override
  String get layer_quartiers_sub => 'Zones de la ville';

  @override
  String get layer_photos => 'Photos épinglées';

  @override
  String get layer_photos_sub => 'Découvertes communautaires';

  @override
  String get btn_close => 'Fermer';

  @override
  String get btn_back => 'Retour';

  @override
  String get btn_create => 'Créer';

  @override
  String get btn_cancel => 'Annuler';

  @override
  String get btn_discard => 'Abandonner';

  @override
  String get btn_resume => 'Reprendre';

  @override
  String get exit_start_session => 'Démarrer une sortie';

  @override
  String get exit_start_session_cta => 'Démarrer la sortie';

  @override
  String get mode_free_circuit => 'Circuit libre';

  @override
  String get mode_free_default => 'Par défaut';

  @override
  String get mode_itinerary => 'Itinéraire';

  @override
  String get mode_itinerary_choose => 'Choisir →';

  @override
  String get gps_mode_ready => 'Mode auto-détecté · GPS prêt';

  @override
  String get navigate_with_title => 'Naviguer avec…';

  @override
  String get btn_lets_go => 'C\'est parti !';

  @override
  String get my_itineraries => 'Mes itinéraires';

  @override
  String get nav_gps_integrated => 'GPS intégré';

  @override
  String get nav_gps_recommended => 'Recommandé';

  @override
  String get nav_apple_plans => 'Apple Plans';

  @override
  String get nav_apple_maps_app => 'Application Maps';

  @override
  String get nav_google_maps => 'Google Maps';

  @override
  String get nav_external_app => 'Application externe';

  @override
  String get nav_waze => 'Waze';

  @override
  String get nav_car_only => 'Voiture uniquement';

  @override
  String get add_steps => 'Ajouter des étapes';

  @override
  String step_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '$count étape',
    );
    return '$_temp0';
  }

  @override
  String get tab_manual => 'Manuel';

  @override
  String get tab_auto => 'Auto ✨';

  @override
  String get steps_title => 'Étapes du parcours';

  @override
  String step_counter_badge(int count) {
    return '$count / min. 3';
  }

  @override
  String get itinerary_name_hint => 'Nommer cet itinéraire… (optionnel)';

  @override
  String get empty_no_steps => 'Aucune étape pour l\'instant';

  @override
  String get empty_select_places => 'Sélectionne des lieux sur la carte';

  @override
  String get btn_create_itinerary => 'Créer l\'itinéraire';

  @override
  String get generating_loading => 'Génération en cours…';

  @override
  String get auto_gen_title => 'Génération automatique';

  @override
  String get auto_gen_description =>
      'Maximise les rues non explorées autour de toi';

  @override
  String get time_unit_minutes => 'min';

  @override
  String get btn_generate_itinerary => 'Générer l\'itinéraire';

  @override
  String get btn_regenerate => 'Regénérer';

  @override
  String get btn_use_itinerary => 'Utiliser cet itinéraire';

  @override
  String get offline_mode_message => 'Mode hors-ligne — carte limitée au cache';

  @override
  String get resume_session_title => 'Reprendre la session précédente ?';

  @override
  String get session_interrupted_message =>
      'Une session a été interrompue. Tu peux la reprendre ou l\'abandonner.';

  @override
  String get error_map_style => 'Impossible de charger le style de la carte.';

  @override
  String get search_placeholder => 'Rechercher un lieu…';

  @override
  String get filters_title => 'Filtres';

  @override
  String get btn_reset_filters => 'Réinitialiser';

  @override
  String active_filter_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtres actifs',
      one: '$count filtre actif',
    );
    return '$_temp0';
  }

  @override
  String get session_completed => 'Sortie terminée';

  @override
  String get stat_streets => 'Rues explorées';

  @override
  String get stat_distance => 'Distance';

  @override
  String get stat_duration => 'Durée';

  @override
  String get stat_mode => 'Mode';

  @override
  String get btn_back_to_map => 'Retour à la carte';

  @override
  String get gps_required_title => 'GPS requis';

  @override
  String get gps_required_message =>
      'Le GPS est requis pour colorier tes rues.\nActive-le dans les Réglages pour continuer.';

  @override
  String get btn_open_settings => 'Ouvrir les réglages';

  @override
  String get btn_see_more => 'Voir plus';

  @override
  String get zones_show => 'Voir les zones explorées';

  @override
  String get zones_hide => 'Cacher les zones explorées';

  @override
  String get tab_map => 'Carte';

  @override
  String get tab_itineraries => 'Parcours';

  @override
  String get tab_social => 'Social';

  @override
  String get tab_badges => 'Badges';

  @override
  String get tab_profile => 'Profil';

  @override
  String nav_tab_semantics(String name, int index, int total) {
    return '$name, onglet $index sur $total';
  }

  @override
  String session_counter_text(int streets, String distance, String time) {
    return '$streets rues · $distance · $time';
  }

  @override
  String session_status_text(int streets, String distance) {
    return 'Circuit libre · $streets rues · $distance';
  }

  @override
  String session_status_semantics(int streets, String distance, String time) {
    return 'Session en cours : $streets rues, $distance, $time';
  }

  @override
  String get app_tagline => 'Every detour hides a discovery.';

  @override
  String get privacy_gps_title => 'Localisation GPS';

  @override
  String get privacy_gps_body =>
      'Urbink utilise ton GPS pour colorier les rues que tu parcours en temps réel pendant une session active. Le tracking s\'arrête lorsque la session est mise en pause ou stoppée.';

  @override
  String get privacy_anon_title => 'Compte anonyme';

  @override
  String get privacy_anon_body =>
      'Ta progression est sauvegardée sous un identifiant anonyme. Aucune donnée personnelle n\'est requise pour utiliser Urbink.';

  @override
  String get privacy_maps_title => 'Données cartographiques';

  @override
  String get privacy_maps_body =>
      '© OpenStreetMap contributors — données cartographiques sous licence ODbL.';

  @override
  String get btn_accept_continue => 'Accepter et continuer';

  @override
  String get privacy_footer =>
      'En continuant, tu acceptes notre politique de confidentialité.';

  @override
  String get session_live => 'Sortie en cours';

  @override
  String get session_duration => 'Durée';

  @override
  String get streets => 'Rues';

  @override
  String get pace => 'Allure';

  @override
  String get btn_stop => 'Arrêter la sortie';

  @override
  String get live_progress => 'Progression en direct';

  @override
  String get zone_progress => 'Zone explorée';

  @override
  String get new_streets => 'Nouvelles rues';

  @override
  String get calories => 'Calories';

  @override
  String get tip_title => 'Astuce';

  @override
  String get mode_libre => 'Libre';

  @override
  String get sum_title => 'Sortie terminée !';

  @override
  String get sum_sub => 'Belle exploration, continuez comme ça';

  @override
  String get sum_streets => 'rues explorées';

  @override
  String get sum_km => 'kilomètres';

  @override
  String get sum_duration => 'durée';

  @override
  String get sum_new_badges => 'nouveaux badges';

  @override
  String sum_badges_unlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count badges débloqués !',
      one: '$count badge débloqué !',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get sum_share => 'Partager';

  @override
  String get sum_done => 'Super !';

  @override
  String get celeb_title => 'Badge débloqué !';

  @override
  String get celeb_continue => 'Continuer l\'exploration';

  @override
  String get celeb_skip => 'Ignorer';

  @override
  String celeb_progress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get profile_title => 'Vous';

  @override
  String get profile_all_sessions => 'Toutes les sorties';

  @override
  String profile_sessions_of(String day) {
    return 'Sorties du $day';
  }

  @override
  String get profile_error_loading => 'Erreur de chargement';

  @override
  String get profile_no_sessions => 'Pas encore de sortie — explore ta ville !';

  @override
  String get profile_no_sessions_day => 'Aucune sortie ce jour-là';

  @override
  String get profile_all_shown => 'Tout affiché';

  @override
  String get profile_view_simple => 'Simple';

  @override
  String get profile_view_feed => 'Feed';

  @override
  String get profile_feed_placeholder => 'Vue feed disponible à l\'Epic 9';

  @override
  String get histogram_empty_message =>
      'Ta première sortie cette semaine n\'attend que toi';

  @override
  String get histogram_start_cta => 'Démarrer';

  @override
  String get challenges_badges_section_title => 'Badges Quartiers';

  @override
  String celeb_district_title(String name) {
    return '🏆 Quartier $name complété !';
  }

  @override
  String get celeb_secret_local_label => 'Secret local';

  @override
  String get celeb_share => 'Partager';

  @override
  String celeb_district_semantics(String name) {
    return 'Badge quartier $name débloqué. Secret local révélé.';
  }

  @override
  String get badges_collections_intro => 'Explorez Paris par thématique';

  @override
  String get badges_collection_complete => 'Collection complète !';

  @override
  String get badges_collection_complete_sub =>
      'Vous avez débloqué tous les monuments';

  @override
  String get badges_stat_collections => 'Collections';

  @override
  String get btn_share => 'Partager';

  @override
  String get btn_show_on_map => 'Voir sur la carte';

  @override
  String get mon_visited => 'Badge débloqué';

  @override
  String get mon_visited_sub => 'Monument visité lors d\'une sortie Urbink';

  @override
  String get mon_locked => 'Pas encore visité';

  @override
  String get mon_locked_sub => 'Approchez-vous à moins de 100 m pour débloquer';

  @override
  String mon_arr(String n) {
    return '$n arr.';
  }

  @override
  String get challenges_monuments_section_title => 'Monuments';

  @override
  String get badge_new => 'Nouveau !';

  @override
  String badge_locked_hint(String radius) {
    return 'Passe à $radius m pour débloquer ce badge.';
  }

  @override
  String get tab_objectifs => 'Objectifs';

  @override
  String get objectif_activate => 'Activer';

  @override
  String get objectif_deactivate => 'Actif';

  @override
  String get objectif_complete => 'Complété';

  @override
  String get transport_foot => 'À pied';

  @override
  String get transport_bike => 'Vélo';

  @override
  String get transport_all => 'Tous modes';

  @override
  String objectif_progress(int unlocked, int total) {
    return '$unlocked / $total monuments';
  }

  @override
  String get rank_explorer_label => 'RANG D\'EXPLORATEUR';

  @override
  String rank_toward_next(String name) {
    return 'Vers $name';
  }

  @override
  String rank_monuments_count(int count) {
    return '$count monuments découverts';
  }

  @override
  String get rank_max_reached => 'Rang maximum atteint';

  @override
  String get rank_all_label => 'Les 11 rangs';

  @override
  String rank_position(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get ranks_screen_title => 'Rang d\'explorateur';

  @override
  String get ranks_screen_subtitle => '1 monument découvert = 1 XP';

  @override
  String rank_hero_label(int current, int total) {
    return 'Rang actuel · $current sur $total';
  }

  @override
  String get rank_next_label => 'Prochain rang';

  @override
  String get rank_you_are_here => 'Vous êtes ici';

  @override
  String get rank_threshold_start => 'Point de départ';

  @override
  String rank_threshold_from(int count) {
    return 'À partir de $count monuments';
  }

  @override
  String get profile_anonymous_name => 'Explorateur Anonyme';

  @override
  String get profile_anonymous_initials => 'EA';

  @override
  String get profile_stat_monuments => 'monuments';

  @override
  String get profile_stat_sorties => 'sorties';

  @override
  String get profile_stat_ville => 'ville';

  @override
  String get profile_last_sessions => 'Dernières sorties';

  @override
  String get badge_new_label => 'NOUVEAU';

  @override
  String get rank_mythic => 'Mythique';
}
