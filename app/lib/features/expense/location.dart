import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n.dart';
import '../../core/location.dart';
import '../../core/server.dart';
import '../../data/models.dart';
import '../../ui/tokens.dart';

/// Sent with every tile request, as tile servers ask apps to say who they are.
const _userAgentPackage = 'me.devvillie.balnana';

/// How close the map comes to a pin.
const _pinZoom = 16.0;

/// The longest place name the server takes.
const maxPlaceLength = 200;

LatLng _latLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

/// [p] folded back onto the globe: the map scrolls round the world sideways.
GeoPoint _geoPoint(LatLng p) =>
    GeoPoint(p.latitude.clamp(-90, 90), ((p.longitude + 180) % 360 + 360) % 360 - 180);

/// Tells why the device's position could not be read.
void showLocationProblem(BuildContext context, LocationProblem problem) {
  final l10n = context.l10n;
  final message = switch (problem) {
    LocationProblem.denied => l10n.locationDenied,
    LocationProblem.off => l10n.locationOff,
    LocationProblem.unavailable => l10n.locationUnavailable,
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Opens [point] in a maps app, or on openstreetmap.org when there is none.
Future<void> openInMaps(BuildContext context, GeoPoint point, String? name) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final lat = point.latitude, lng = point.longitude;
  final label = name == null || name.isEmpty ? '' : '(${Uri.encodeComponent(name)})';
  final web = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng');
  try {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (await launchUrl(Uri.parse('geo:$lat,$lng?q=$lat,$lng$label'))) return;
    }
    if (await launchUrl(web, mode: LaunchMode.externalApplication)) return;
  } on PlatformException {
    // Shown below.
  }
  messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
}

/// A map from the tiles the server set, with a pin at [pin].
class LocationMap extends ConsumerWidget {
  const LocationMap({
    super.key,
    required this.center,
    this.zoom = _pinZoom,
    this.pin,
    this.controller,
    this.onTap,
    this.interactive = true,
  });

  final GeoPoint center;
  final double zoom;
  final GeoPoint? pin;
  final MapController? controller;
  final ValueChanged<GeoPoint>? onTap;
  final bool interactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(serverInfoProvider).value;
    final tiles = info?.mapTiles;
    final scheme = Theme.of(context).colorScheme;
    if (tiles == null) return ColoredBox(color: scheme.surfaceContainerHighest);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pin = this.pin, onTap = this.onTap;
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: _latLng(center),
        initialZoom: zoom,
        minZoom: 2,
        maxZoom: 19,
        backgroundColor: scheme.surfaceContainerHighest,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
        onTap: onTap == null ? null : (_, p) => onTap(_geoPoint(p)),
      ),
      children: [
        TileLayer(
          urlTemplate: tiles,
          userAgentPackageName: _userAgentPackage,
          tileBuilder: dark ? darkModeTileBuilder : null,
        ),
        if (pin != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _latLng(pin),
                width: 48,
                height: 48,
                alignment: Alignment.topCenter,
                child: Icon(Icons.location_on, size: 48, color: scheme.primary),
              ),
            ],
          ),
        if (info!.mapAttribution.isNotEmpty)
          SimpleAttributionWidget(
            source: Text(info.mapAttribution, style: Theme.of(context).textTheme.labelSmall),
            alignment: Alignment.bottomLeft,
            backgroundColor: scheme.surface.withValues(alpha: 0.8),
          ),
      ],
    );
  }
}

/// The location part of the expense editor: a place name to type, and a pin
/// to drop on a map or to put where the device is.
class LocationField extends ConsumerStatefulWidget {
  const LocationField({super.key, required this.name, required this.point, required this.onPoint, this.around});

  final TextEditingController name;
  final GeoPoint? point;
  final ValueChanged<GeoPoint?> onPoint;

  /// Where to start looking on the map when there is no pin yet.
  final GeoPoint? around;

  @override
  ConsumerState<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends ConsumerState<LocationField> {
  bool _finding = false;

  /// Only ever called from a tap on "Use current location".
  Future<void> _useCurrent() async {
    setState(() => _finding = true);
    try {
      final point = await ref.read(currentLocationProvider)();
      if (mounted) widget.onPoint(point);
    } on LocationException catch (e) {
      if (mounted) showLocationProblem(context, e.problem);
    } finally {
      if (mounted) setState(() => _finding = false);
    }
  }

  Future<void> _pick() async {
    final point = await Navigator.of(context).push(
      MaterialPageRoute<GeoPoint>(
        fullscreenDialog: true,
        builder: (_) => LocationPickerPage(pin: widget.point, around: widget.around),
      ),
    );
    if (point != null && mounted) widget.onPoint(point);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final maps = ref.watch(serverInfoProvider.select((i) => i.value?.mapTiles != null));
    final point = widget.point;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.name,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\r\n]')),
            LengthLimitingTextInputFormatter(maxPlaceLength),
          ],
          decoration: InputDecoration(
            hintText: l10n.expenseLocationHint,
            prefixIcon: const Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: BSpace.s12),
        if (point == null)
          Wrap(
            spacing: BSpace.s8,
            runSpacing: BSpace.s8,
            children: [
              OutlinedButton.icon(
                onPressed: _finding ? null : _useCurrent,
                icon: _finding
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: Text(_finding ? l10n.locationFinding : l10n.locationUseCurrent),
              ),
              if (maps)
                OutlinedButton.icon(
                  onPressed: _pick,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(l10n.locationPickOnMap),
                ),
            ],
          )
        else ...[
          if (maps)
            ClipRRect(
              borderRadius: BorderRadius.circular(BShape.md),
              child: SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    // A picture of the place; tapping it opens the full map.
                    Positioned.fill(
                      child: IgnorePointer(child: LocationMap(key: ValueKey(point), center: point, pin: point)),
                    ),
                    Positioned.fill(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(onTap: _pick),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          const SizedBox(height: BSpace.s4),
          Wrap(
            spacing: BSpace.s4,
            children: [
              if (maps)
                TextButton.icon(
                  onPressed: _pick,
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  label: Text(l10n.locationChange),
                ),
              TextButton.icon(
                onPressed: () => openInMaps(context, point, widget.name.text.trim()),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.locationOpenInMaps),
              ),
              TextButton.icon(
                onPressed: () => widget.onPoint(null),
                icon: const Icon(Icons.location_off_outlined),
                label: Text(l10n.locationRemovePin),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A full-screen map to drop a pin on. Pops with the pin, or with nothing
/// when closed.
class LocationPickerPage extends ConsumerStatefulWidget {
  const LocationPickerPage({super.key, this.pin, this.around});

  final GeoPoint? pin;

  /// Where to start when there is no [pin]; the whole world without either.
  final GeoPoint? around;

  @override
  ConsumerState<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
  final _map = MapController();
  late GeoPoint? _pin = widget.pin;
  bool _finding = false;

  /// Only ever called from a tap on the "Use current location" button.
  Future<void> _useCurrent() async {
    setState(() => _finding = true);
    try {
      final point = await ref.read(currentLocationProvider)();
      if (!mounted) return;
      setState(() => _pin = point);
      _map.move(_latLng(point), math.max(_map.camera.zoom, _pinZoom));
    } on LocationException catch (e) {
      if (mounted) showLocationProblem(context, e.problem);
    } finally {
      if (mounted) setState(() => _finding = false);
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final start = widget.pin ?? widget.around;
    final pin = _pin;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.locationPickTitle),
        actions: [
          TextButton(
            onPressed: pin == null ? null : () => Navigator.of(context).pop(pin),
            child: Text(l10n.locationPickDone),
          ),
          const SizedBox(width: BSpace.s8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: LocationMap(
              controller: _map,
              center: start ?? const GeoPoint(20, 0),
              zoom: start == null ? 2 : (widget.pin == null ? 13 : _pinZoom),
              pin: pin,
              onTap: (p) => setState(() => _pin = p),
            ),
          ),
          Positioned(
            top: BSpace.s12,
            left: BSpace.s16,
            right: BSpace.s16,
            child: Center(
              child: Material(
                color: scheme.surfaceContainerHigh,
                shape: const StadiumBorder(),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BSpace.s16, vertical: BSpace.s8),
                  child: Text(l10n.locationPickHint, style: Theme.of(context).textTheme.labelLarge),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.locationUseCurrent,
        onPressed: _finding ? null : _useCurrent,
        child: _finding
            ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.my_location),
      ),
    );
  }
}
