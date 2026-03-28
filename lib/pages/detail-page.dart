import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story/helpers/location-helper.dart';
import 'package:story/l10n/app_localizations.dart';
import 'package:story/models/story_model.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final StoryModel story;

  const DetailPage({super.key, required this.story});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  bool _showMap = false;
  bool _isLoadingMap = true;

  @override
  void initState() {
    super.initState();
    _adjustMarker();
  }

  void _adjustMarker() async {
    final lat = widget.story.lat;
    final lon = widget.story.lon;

    if (lat == null || lon == null) {
      if (mounted) {
        setState(() {
          _isLoadingMap = false;
        });
      }
      return;
    }

    final place = await LocationHelper().getLocationName(lat, lon);

    if (place.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingMap = false;
        });
      }
      return;
    }

    final marker = Marker(
      markerId: const MarkerId("storyLocation"),
      position: LatLng(lat, lon),
      infoWindow: InfoWindow(title: place),
      onTap: () {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lon), 18),
        );
      },
    );
    markers.add(marker);
    if (mounted) {
      setState(() {
        _showMap = true;
        _isLoadingMap = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final story = widget.story;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailStory)),
      body: Stack(
        children: [
          if (_isLoadingMap)
            const Center(child: CircularProgressIndicator())
          else if (_showMap)
            Center(
              child: GoogleMap(
                markers: markers,
                initialCameraPosition: CameraPosition(
                  zoom: 18,
                  target: LatLng(widget.story.lat!, widget.story.lon!),
                ),
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
            )
          else
            Center(child: Text(l10n.locationNotAvailable)),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(),
                                Text(
                                  story.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.network(
                            story.photoUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateFormat.format(story.createdAt),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
