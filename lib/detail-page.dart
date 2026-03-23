import 'package:flutter/material.dart';
import 'package:story/story-model.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final StoryModel story;

  const DetailPage({super.key, required this.story});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String locationName = 'Loading location...';

  @override
  void initState() {
    super.initState();
    _getLocationName();
  }

  Future<void> _getLocationName() async {
    final lat = widget.story.lat;
    final lon = widget.story.lon;

    if (lat != null && lon != null) {
      try {
        final placemarks = await geo.placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            locationName = [
              place.subLocality,
              place.locality,
              place.country,
            ].where((e) => e != null && e!.isNotEmpty).join(', ');
          });
          return;
        }
      } catch (e) {
        setState(() {
          locationName = 'Location not available';
        });
        return;
      }
    }

    setState(() {
      locationName = (lat != null && lon != null)
          ? 'Unknown location ($lat, $lon)'
          : 'Location not available';
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Story')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              story.photoUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(story.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationName,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
