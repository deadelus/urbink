import 'package:flutter/material.dart';

class PoiFilter {
  const PoiFilter({
    required this.id,
    required this.label,
    required this.icon,
    required this.categoryId,
  });

  final String id;
  final String label;
  final IconData icon;
  final String categoryId;
}

class PoiFilterCategory {
  const PoiFilterCategory({
    required this.id,
    required this.label,
    required this.filters,
  });

  final String id;
  final String label;
  final List<PoiFilter> filters;
}

const poiFilterCategories = <PoiFilterCategory>[
  PoiFilterCategory(
    id: 'culture',
    label: 'Culture & Patrimoine',
    filters: [
      PoiFilter(id: 'monuments',  label: 'Monuments',  icon: Icons.account_balance_rounded, categoryId: 'culture'),
      PoiFilter(id: 'musees',     label: 'Musées',     icon: Icons.museum_rounded,          categoryId: 'culture'),
      PoiFilter(id: 'galeries',   label: 'Galeries',   icon: Icons.photo_library_rounded,   categoryId: 'culture'),
      PoiFilter(id: 'theatres',   label: 'Théâtres',   icon: Icons.theater_comedy_rounded,  categoryId: 'culture'),
      PoiFilter(id: 'cinemas',    label: 'Cinémas',    icon: Icons.movie_rounded,           categoryId: 'culture'),
    ],
  ),
  PoiFilterCategory(
    id: 'nature',
    label: 'Nature & Espaces verts',
    filters: [
      PoiFilter(id: 'parcs',    label: 'Parcs',    icon: Icons.park_rounded,         categoryId: 'nature'),
      PoiFilter(id: 'jardins',  label: 'Jardins',  icon: Icons.grass_rounded,        categoryId: 'nature'),
      PoiFilter(id: 'forets',   label: 'Forêts',   icon: Icons.forest_rounded,       categoryId: 'nature'),
      PoiFilter(id: 'plages',   label: 'Plages',   icon: Icons.beach_access_rounded, categoryId: 'nature'),
    ],
  ),
  PoiFilterCategory(
    id: 'gastronomie',
    label: 'Gastronomie',
    filters: [
      PoiFilter(id: 'cafes',        label: 'Cafés',        icon: Icons.local_cafe_rounded,       categoryId: 'gastronomie'),
      PoiFilter(id: 'restaurants',  label: 'Restaurants',  icon: Icons.restaurant_rounded,       categoryId: 'gastronomie'),
      PoiFilter(id: 'boulangeries', label: 'Boulangeries', icon: Icons.bakery_dining_rounded,    categoryId: 'gastronomie'),
      PoiFilter(id: 'marches',      label: 'Marchés',      icon: Icons.storefront_rounded,       categoryId: 'gastronomie'),
      PoiFilter(id: 'bars',         label: 'Bars',         icon: Icons.local_bar_rounded,        categoryId: 'gastronomie'),
    ],
  ),
  PoiFilterCategory(
    id: 'sport',
    label: 'Sport & Loisirs',
    filters: [
      PoiFilter(id: 'stades',      label: 'Stades',          icon: Icons.stadium_rounded,       categoryId: 'sport'),
      PoiFilter(id: 'gymnases',    label: 'Salles de sport', icon: Icons.fitness_center_rounded, categoryId: 'sport'),
      PoiFilter(id: 'piscines',    label: 'Piscines',        icon: Icons.pool_rounded,           categoryId: 'sport'),
      PoiFilter(id: 'velos',       label: 'Vélos',           icon: Icons.pedal_bike_rounded,     categoryId: 'sport'),
      PoiFilter(id: 'skateparks',  label: 'Skateparks',      icon: Icons.skateboarding_rounded,  categoryId: 'sport'),
    ],
  ),
  PoiFilterCategory(
    id: 'transports',
    label: 'Transports',
    filters: [
      PoiFilter(id: 'gares',       label: 'Gares',          icon: Icons.train_rounded,         categoryId: 'transports'),
      PoiFilter(id: 'metro',       label: 'Métro',          icon: Icons.subway_rounded,        categoryId: 'transports'),
      PoiFilter(id: 'bus',         label: 'Bus',            icon: Icons.directions_bus_rounded, categoryId: 'transports'),
      PoiFilter(id: 'velo_partage',label: 'Vélos partagés', icon: Icons.electric_bike_rounded,  categoryId: 'transports'),
    ],
  ),
  PoiFilterCategory(
    id: 'shopping',
    label: 'Shopping',
    filters: [
      PoiFilter(id: 'boutiques',  label: 'Boutiques',  icon: Icons.shopping_bag_rounded,       categoryId: 'shopping'),
      PoiFilter(id: 'librairies', label: 'Librairies', icon: Icons.menu_book_rounded,           categoryId: 'shopping'),
      PoiFilter(id: 'epiceries',  label: 'Épiceries',  icon: Icons.local_grocery_store_rounded, categoryId: 'shopping'),
    ],
  ),
];

/// Accès rapide — affichés dans la barre horizontale
const quickPoiFilters = <PoiFilter>[
  PoiFilter(id: 'monuments',   label: 'Monuments',   icon: Icons.account_balance_rounded, categoryId: 'culture'),
  PoiFilter(id: 'parcs',       label: 'Parcs',       icon: Icons.park_rounded,            categoryId: 'nature'),
  PoiFilter(id: 'cafes',       label: 'Cafés',       icon: Icons.local_cafe_rounded,      categoryId: 'gastronomie'),
  PoiFilter(id: 'musees',      label: 'Musées',      icon: Icons.museum_rounded,          categoryId: 'culture'),
  PoiFilter(id: 'restaurants', label: 'Restaurants', icon: Icons.restaurant_rounded,      categoryId: 'gastronomie'),
];
