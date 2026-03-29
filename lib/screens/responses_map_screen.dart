import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:lighthouse/nav.dart';
import 'package:lighthouse/theme.dart';

class ResponsesMapScreen extends StatefulWidget {
  const ResponsesMapScreen({super.key, required this.disasters});

  /// Each entry should include: id, name, location_name, lat, lng (optional).
  final List<Map<String, dynamic>> disasters;

  @override
  State<ResponsesMapScreen> createState() => _ResponsesMapScreenState();
}

class _ResponsesMapScreenState extends State<ResponsesMapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToMarkersIfPossible());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitToMarkersIfPossible() {
    final points = _itemsWithCoords
        .map((d) => LatLng(_toDouble(d['lat']), _toDouble(d['lng'])))
        .where((p) => p.latitude.isFinite && p.longitude.isFinite)
        .toList(growable: false);
    if (points.isEmpty) return;

    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(56),
        ),
      );
    } catch (_) {
      // No-op: map may not be ready yet on some platforms; initial center still works.
    }
  }

  List<Map<String, dynamic>> get _itemsWithCoords => widget.disasters
      .where((d) => d['lat'] != null && d['lng'] != null)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _itemsWithCoords;

    final LatLng initialCenter = items.isNotEmpty
        ? LatLng(_toDouble(items.first['lat']), _toDouble(items.first['lng']))
        : const LatLng(15, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Response Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: items.isNotEmpty ? 4 : 2,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                        onMapReady: _fitToMarkersIfPossible,
                      ),
                      children: [
                        TileLayer(
                          // Colored, Google-Maps-like basemap (no API key needed).
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'lighthouse',
                        ),
                        MarkerLayer(
                          markers: [
                            for (final d in items)
                              Marker(
                                point: LatLng(_toDouble(d['lat']), _toDouble(d['lng'])),
                                width: 44,
                                height: 44,
                                alignment: Alignment.bottomCenter,
                                child: _ResponseMarker(
                                  disasterId: (d['id'] as String?) ?? '',
                                  name: (d['name'] as String?) ?? 'Response',
                                  location: (d['location_name'] as String?) ?? 'Unknown location',
                                  lat: _toDouble(d['lat']),
                                  lng: _toDouble(d['lng']),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: _MapLegend(total: widget.disasters.length, withCoords: items.length),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double _toDouble(Object? v) {
    if (v == null) return double.nan;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? double.nan;
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.total, required this.withCoords});

  final int total;
  final int withCoords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Active responses: $total  •  Mapped: $withCoords',
                style: context.textStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.open_with_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text('Pan/Zoom', style: context.textStyles.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ResponseMarker extends StatelessWidget {
  const _ResponseMarker({required this.disasterId, required this.name, required this.location, required this.lat, required this.lng});

  final String disasterId;
  final String name;
  final String location;
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: '$name\n$location\n($lat, $lng)',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.push(
            AppRoutes.projectDetailPublic,
            extra: {
              'id': disasterId,
              'name': name,
              'location_name': location,
              'lat': lat,
              'lng': lng,
            },
          );
        },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.location_on_rounded, size: 42, color: theme.colorScheme.primary),
              Positioned(
                top: 10,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
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
