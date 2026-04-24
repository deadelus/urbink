import 'package:flutter/material.dart';
import 'package:urbink/features/map/models/map_layer.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';

class MapLayersSection extends StatefulWidget {
  final Map<String, bool> values;
  final ValueChanged<Map<String, bool>> onChanged;

  const MapLayersSection({
    super.key,
    required this.values,
    required this.onChanged,
  });

  @override
  State<MapLayersSection> createState() => _MapLayersSectionState();
}

class _MapLayersSectionState extends State<MapLayersSection> {
  void _toggle(String key) {
    final updated = Map<String, bool>.from(widget.values);
    updated[key] = !(widget.values[key] ?? false);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final layers = [
      MapLayer(
        key: 'monuments',
        label: l10n.layer_monuments,
        sub: l10n.layer_monuments_sub,
        initial: true,
      ),
      MapLayer(
        key: 'quartiers',
        label: l10n.layer_quartiers,
        sub: l10n.layer_quartiers_sub,
        initial: false,
      ),
      MapLayer(
        key: 'photos',
        label: l10n.layer_photos,
        sub: l10n.layer_photos_sub,
        initial: false,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: UrbinkColors.surfaceVariant,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              l10n.layers_title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: UrbinkColors.onSurface,
              ),
            ),
          ),
          const _RowDivider(),
          for (int i = 0; i < layers.length; i++) ...[
            if (i > 0) const _RowDivider(),
            _LayerRow(
              layer: layers[i],
              value: widget.values[layers[i].key] ?? layers[i].initial,
              onToggle: () => _toggle(layers[i].key),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: UrbinkColors.border,
    );
  }
}

// ---------------------------------------------------------------------------

class _LayerRow extends StatelessWidget {
  final MapLayer layer;
  final bool value;
  final VoidCallback onToggle;

  const _LayerRow({
    required this.layer,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: value,
      label: '${layer.label}. ${layer.sub}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        layer.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: UrbinkColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        layer.sub,
                        style: const TextStyle(
                          fontSize: 11,
                          color: UrbinkColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
                AbsorbPointer(
                  child: Transform.scale(
                    scale: 0.77,
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: value,
                      // non-null → rendu enabled, absorb gère les taps
                      onChanged: (_) {},
                      thumbColor: WidgetStateProperty.all(Colors.white),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return UrbinkColors.primary;
                        }
                        return UrbinkColors.sheetDragPill;
                      }),
                      trackOutlineColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return UrbinkColors.primary;
                        }
                        return UrbinkColors.sheetDragPill;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
