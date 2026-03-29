import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story/helpers/location_helper.dart';
import 'package:story/l10n/app_localizations.dart';
import 'package:story/providers/config_provider.dart';
import 'package:story/proxys/story_proxy.dart';

class UploadPage extends StatefulWidget {
  final Function() onUpload;
  final Function() onMapTap;
  final LatLng? pickedLocation;
  const UploadPage({
    super.key,
    required this.onUpload,
    required this.onMapTap,
    this.pickedLocation,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _locationName = "";
  Position? _position;
  LatLng? _selectedLatLng;
  @override
  void initState() {
    super.initState();
    _getLocationName();
  }

  @override
  void didUpdateWidget(covariant UploadPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickedLocation != oldWidget.pickedLocation &&
        widget.pickedLocation != null) {
      _updateSelectedLocation(widget.pickedLocation!);
    }
  }

  Future<void> _updateSelectedLocation(LatLng selected) async {
    String newLocation = await LocationHelper().getLocationName(
      selected.latitude,
      selected.longitude,
    );
    setState(() {
      _selectedLatLng = selected;
      _locationName = newLocation;
    });
  }

  Future<void> _getLocationName() async {
    _position = await LocationHelper().determinePosition();
    if (_position != null) {
      final locationName = await LocationHelper().getLocationName(
        _position!.latitude,
        _position!.longitude,
      );
      setState(() {
        _locationName = locationName;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedPickImage(e.toString()))),
      );
    }
  }

  Future<void> _uploadStory() async {
    final l10n = AppLocalizations.of(context)!;

    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectImage)));
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterDescription)));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      double? lat = _selectedLatLng?.latitude ?? _position?.latitude;
      double? lon = _selectedLatLng?.longitude ?? _position?.longitude;

      final success = await StoryProxy().uploadStory(
        file: _imageFile!,
        description: description,
        lat: lat,
        lon: lon,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.uploadSuccess)));
        widget.onUpload();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.uploadFailed(e.toString()))));
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadStory)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.image, size: 100, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l10n.camera),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: Text(l10n.gallery),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.description,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                hintText: l10n.descriptionHint,
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_locationName, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    if (!ConfigProvider.isFree) {
                      LocationPermission permission =
                          await Geolocator.checkPermission();

                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.denied) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.locationPermissionDenied),
                            ),
                          );
                          return;
                        }
                      }

                      if (permission == LocationPermission.deniedForever) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.locationPermissionDeniedForever),
                          ),
                        );
                        return;
                      }

                      widget.onMapTap();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.featureNotAvailable)),
                      );
                    }
                  },
                  child: Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              child: ElevatedButton(
                onPressed: !_isUploading ? _uploadStory : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.upload,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
