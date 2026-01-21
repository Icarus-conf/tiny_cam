import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';

import '../services/camera_service.dart';
import '../services/filter_service.dart';
import '../widgets/toast_notification.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraMacOSController? _controller;
  final CameraService _cameraService = CameraService();
  bool _isCapturing = false;
  bool _isMirrored = false;
  String? _toastMessage;
  bool _isToastError = false;
  Timer? _messageTimer;
  File? _latestImage;
  FilterType _selectedFilter = FilterType.none;
  bool _showFilters = false;
  CameraMacOSMode _cameraMode = CameraMacOSMode.photo;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _loadLatestImage();
  }

  Future<void> _loadLatestImage() async {
    final media = await _cameraService.getAllMedia();
    if (media.isNotEmpty && mounted) {
      setState(() {
        _latestImage = media.first;
      });
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    _messageTimer?.cancel();
    setState(() {
      _toastMessage = message;
      _isToastError = isError;
    });

    _messageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _toastMessage = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: ColorFiltered(
              colorFilter: FilterService.getPreviewFilter(_selectedFilter),
              child: Transform(
                alignment: Alignment.center,
                transform: _isMirrored ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
                child: CameraMacOSView(
                  fit: BoxFit.cover,
                  cameraMode: _cameraMode,
                  pictureFormat: PictureFormat.png,
                  resolution: PictureResolution.max,
                  onCameraInizialized: (controller) {
                    setState(() => _controller = controller);
                  },
                ),
              ),
            ),
          ),

          // Flash effect overlay
          if (_isCapturing || _isRecording)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: _isRecording ? Colors.red : Colors.green, width: 8),
              ),
              child: _isRecording
                  ? SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'REC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),

          // Mirror Toggle Button
          Positioned(
            top: 40,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isMirrored ? Icons.flip_camera_android : Icons.camera_front,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() => _isMirrored = !_isMirrored);
                    },
                    tooltip: 'Toggle Mirroring',
                  ),
                ),
              ),
            ),
          ),

          // Toast Notification
          Positioned(
            top: 100, // Positioned below the top buttons
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _toastMessage != null
                    ? ToastNotification(
                        key: ValueKey(_toastMessage),
                        message: _toastMessage!,
                        isError: _isToastError,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          // Filter Selector Overlay
          // Premium Filter Selector Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuart,
            bottom: _showFilters ? 110 : -160,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: FilterService.availableFilters.length,
                itemBuilder: (context, index) {
                  final filter = FilterService.availableFilters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 15),
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Filter Preview (Icon + Background)
                            Container(
                              color: Colors.grey[900],
                              child: ColorFiltered(
                                colorFilter: FilterService.getPreviewFilter(filter),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=100&h=100&fit=crop',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.image, color: Colors.white24)),
                                ),
                              ),
                            ),
                            // Filter Name Overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                color: isSelected ? Colors.white : Colors.black54,
                                child: Text(
                                  FilterService.getFilterName(filter),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Filter Toggle Button
                IconButton(
                  icon: Icon(
                    Icons.auto_fix_high,
                    color: _showFilters ? Colors.greenAccent : Colors.white,
                    size: 30,
                  ),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),

                // Capture Button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ModeButton(
                          label: 'PHOTO',
                          isSelected: _cameraMode == CameraMacOSMode.photo,
                          onPressed: () {
                            if (!_isRecording) {
                              setState(() => _cameraMode = CameraMacOSMode.photo);
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _ModeButton(
                          label: 'VIDEO',
                          isSelected: _cameraMode == CameraMacOSMode.video,
                          onPressed: () {
                            if (!_isRecording) {
                              setState(() => _cameraMode = CameraMacOSMode.video);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _CaptureButton(
                      isRecording: _isRecording,
                      isPhotoMode: _cameraMode == CameraMacOSMode.photo,
                      onPressed: _handleCapture,
                    ),
                  ],
                ),

                // Placeholder for balancing the Row (since gallery is absolute positioned)
                const SizedBox(width: 50),
              ],
            ),
          ),

          // Gallery Preview Button
          if (_latestImage != null)
            Positioned(
              bottom: 45,
              right: 40,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GalleryScreen()),
                  );
                  _loadLatestImage(); // Refresh when returning
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.black,
                  ),
                  child: ClipOval(
                    child: _latestImage!.path.endsWith('.mp4')
                        ? FutureBuilder<Uint8List?>(
                            future: _cameraService.getVideoThumbnailData(_latestImage!.path),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.memory(snapshot.data!, fit: BoxFit.cover);
                              }
                              return const Icon(Icons.videocam, color: Colors.white);
                            },
                          )
                        : Image.file(_latestImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleCapture() async {
    if (_cameraMode == CameraMacOSMode.photo) {
      await _takePicture();
    } else {
      await _toggleRecording();
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final path = await _cameraService.takePictureAndSave(_controller!, filter: _selectedFilter);

      if (mounted) {
        setState(() {
          _isCapturing = false;
        });

        if (path != null) {
          _showToast('Saved: ${path.split('/').last}');
          _loadLatestImage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        _showToast('Error: $e', isError: true);
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null) return;

    if (_isRecording) {
      // Stop recording
      try {
        final file = await _controller!.stopRecording();
        setState(() => _isRecording = false);

        if (file != null) {
          final path = await _cameraService.saveVideo(file);
          if (path != null) {
            _showToast('Video saved: ${path.split('/').last}');
            _loadLatestImage();
          }
        }
      } catch (e) {
        log('Error stopping recording: $e');
        _showToast('Error stopping recording', isError: true);
        setState(() => _isRecording = false);
      }
    } else {
      // Start recording
      try {
        await _controller!.recordVideo();
        setState(() => _isRecording = true);
      } catch (e) {
        log('Error starting recording: $e');
        _showToast('Error starting recording', isError: true);
      }
    }
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ModeButton({required this.label, required this.isSelected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 4 : 0,
            height: 4,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isRecording;
  final bool isPhotoMode;

  const _CaptureButton({
    required this.onPressed,
    required this.isRecording,
    required this.isPhotoMode,
  });

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
            ),
          ),
          // Inner circle
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - _controller.value,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: widget.isRecording ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: widget.isRecording ? BorderRadius.circular(8) : null,
                    color: widget.isPhotoMode ? Colors.white : Colors.red,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
