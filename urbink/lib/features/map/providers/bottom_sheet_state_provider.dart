import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Normalized size (0.0–0.65) of the DraggableScrollableSheet.
/// Updated by SortiesBottomSheet on each controller tick.
/// Read by MapScreen for dynamic floating button positioning.
final bottomSheetSizeProvider = StateProvider<double>((ref) => 0.0);
