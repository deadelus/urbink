// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get layers_title => 'Map display';

  @override
  String get layer_monuments => 'Visited monuments';

  @override
  String get layer_monuments_sub => 'Official POIs on the map';

  @override
  String get layer_quartiers => 'District boundaries';

  @override
  String get layer_quartiers_sub => 'City areas';

  @override
  String get layer_photos => 'Pinned photos';

  @override
  String get layer_photos_sub => 'Community discoveries';

  @override
  String get btn_close => 'Close';

  @override
  String get btn_back => 'Back';

  @override
  String get btn_create => 'Create';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_discard => 'Discard';

  @override
  String get btn_resume => 'Resume';

  @override
  String get exit_start_session => 'Start an outing';

  @override
  String get exit_start_session_cta => 'Start the outing';

  @override
  String get mode_free_circuit => 'Free roam';

  @override
  String get mode_free_default => 'Default';

  @override
  String get mode_itinerary => 'Itinerary';

  @override
  String get mode_itinerary_choose => 'Choose →';

  @override
  String get gps_mode_ready => 'Auto-detected mode · GPS ready';

  @override
  String get navigate_with_title => 'Navigate with…';

  @override
  String get btn_lets_go => 'Let\'s go!';

  @override
  String get my_itineraries => 'My itineraries';

  @override
  String get nav_gps_integrated => 'Built-in GPS';

  @override
  String get nav_gps_recommended => 'Recommended';

  @override
  String get nav_apple_plans => 'Apple Maps';

  @override
  String get nav_apple_maps_app => 'Maps app';

  @override
  String get nav_google_maps => 'Google Maps';

  @override
  String get nav_external_app => 'External app';

  @override
  String get nav_waze => 'Waze';

  @override
  String get nav_car_only => 'Car only';

  @override
  String get add_steps => 'Add steps';

  @override
  String step_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String get tab_manual => 'Manual';

  @override
  String get tab_auto => 'Auto ✨';

  @override
  String get steps_title => 'Route steps';

  @override
  String step_counter_badge(int count) {
    return '$count / min. 3';
  }

  @override
  String get itinerary_name_hint => 'Name this itinerary… (optional)';

  @override
  String get empty_no_steps => 'No steps yet';

  @override
  String get empty_select_places => 'Select places on the map';

  @override
  String get btn_create_itinerary => 'Create itinerary';

  @override
  String get generating_loading => 'Generating…';

  @override
  String get auto_gen_title => 'Auto-generate';

  @override
  String get auto_gen_description => 'Maximise unexplored streets around you';

  @override
  String get time_unit_minutes => 'min';

  @override
  String get btn_generate_itinerary => 'Generate itinerary';

  @override
  String get btn_regenerate => 'Regenerate';

  @override
  String get btn_use_itinerary => 'Use this itinerary';

  @override
  String get offline_mode_message => 'Offline mode — map limited to cache';

  @override
  String get resume_session_title => 'Resume previous session?';

  @override
  String get session_interrupted_message =>
      'A session was interrupted. You can resume or discard it.';

  @override
  String get error_map_style => 'Unable to load map style.';

  @override
  String get search_placeholder => 'Search a place…';

  @override
  String get filters_title => 'Filters';

  @override
  String get btn_reset_filters => 'Reset';

  @override
  String active_filter_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active filters',
      one: '$count active filter',
    );
    return '$_temp0';
  }

  @override
  String get session_completed => 'Outing complete';

  @override
  String get stat_streets => 'Streets explored';

  @override
  String get stat_distance => 'Distance';

  @override
  String get stat_duration => 'Duration';

  @override
  String get stat_mode => 'Mode';

  @override
  String get btn_back_to_map => 'Back to map';

  @override
  String get gps_required_title => 'GPS required';

  @override
  String get gps_required_message =>
      'GPS is required to colour your streets.\nEnable it in Settings to continue.';

  @override
  String get btn_open_settings => 'Open settings';

  @override
  String get btn_see_more => 'See more';

  @override
  String get zones_show => 'Show explored zones';

  @override
  String get zones_hide => 'Hide explored zones';

  @override
  String get tab_map => 'Map';

  @override
  String get tab_itineraries => 'Routes';

  @override
  String get tab_social => 'Social';

  @override
  String get tab_badges => 'Badges';

  @override
  String get tab_profile => 'Profile';

  @override
  String nav_tab_semantics(String name, int index, int total) {
    return '$name, tab $index of $total';
  }

  @override
  String session_counter_text(int streets, String distance, String time) {
    return '$streets streets · $distance · $time';
  }

  @override
  String session_status_text(int streets, String distance) {
    return 'Free roam · $streets streets · $distance';
  }

  @override
  String session_status_semantics(int streets, String distance, String time) {
    return 'Session in progress: $streets streets, $distance, $time';
  }

  @override
  String get app_tagline => 'Every detour hides a discovery.';

  @override
  String get privacy_gps_title => 'GPS location';

  @override
  String get privacy_gps_body =>
      'Urbink uses your GPS to colour the streets you walk in real time during an active session. Tracking stops when the session is paused or stopped.';

  @override
  String get privacy_anon_title => 'Anonymous account';

  @override
  String get privacy_anon_body =>
      'Your progress is saved under an anonymous identifier. No personal data is required to use Urbink.';

  @override
  String get privacy_maps_title => 'Map data';

  @override
  String get privacy_maps_body =>
      '© OpenStreetMap contributors — map data under ODbL licence.';

  @override
  String get btn_accept_continue => 'Accept and continue';

  @override
  String get privacy_footer => 'By continuing, you accept our privacy policy.';

  @override
  String get session_live => 'Session active';

  @override
  String get session_duration => 'Duration';

  @override
  String get streets => 'Streets';

  @override
  String get pace => 'Pace';

  @override
  String get btn_stop => 'Stop session';

  @override
  String get live_progress => 'Live progress';

  @override
  String get zone_progress => 'Zone explored';

  @override
  String get new_streets => 'New streets';

  @override
  String get calories => 'Calories';

  @override
  String get tip_title => 'Tip';

  @override
  String get mode_libre => 'Free';

  @override
  String get sum_title => 'Session complete!';

  @override
  String get sum_sub => 'Great exploration, keep going';

  @override
  String get sum_streets => 'streets explored';

  @override
  String get sum_km => 'kilometers';

  @override
  String get sum_duration => 'duration';

  @override
  String get sum_new_badges => 'new badges';

  @override
  String sum_badges_unlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count badges unlocked!',
      one: '$count badge unlocked!',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get sum_share => 'Share';

  @override
  String get sum_done => 'Awesome!';

  @override
  String get celeb_title => 'Badge unlocked!';

  @override
  String get celeb_continue => 'Keep exploring';

  @override
  String get celeb_skip => 'Skip';

  @override
  String celeb_progress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get profile_title => 'You';

  @override
  String get profile_all_sessions => 'All outings';

  @override
  String profile_sessions_of(String day) {
    return 'Outings from $day';
  }

  @override
  String get profile_error_loading => 'Loading error';

  @override
  String get profile_no_sessions => 'No outings yet — explore your city!';

  @override
  String get profile_no_sessions_day => 'No outings that day';

  @override
  String get profile_all_shown => 'All shown';

  @override
  String get profile_view_simple => 'Simple';

  @override
  String get profile_view_feed => 'Feed';

  @override
  String get profile_feed_placeholder => 'Feed view coming in Epic 9';

  @override
  String get histogram_empty_message =>
      'Your first outing this week is waiting for you';

  @override
  String get histogram_start_cta => 'Start';

  @override
  String get challenges_badges_section_title => 'District Badges';

  @override
  String celeb_district_title(String name) {
    return '🏆 District $name completed!';
  }

  @override
  String get celeb_secret_local_label => 'Local secret';

  @override
  String get celeb_share => 'Share';

  @override
  String celeb_district_semantics(String name) {
    return 'District badge $name unlocked. Local secret revealed.';
  }
}
