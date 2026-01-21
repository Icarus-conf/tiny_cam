# 📸 Tiny Cam (macOS Only)

A minimalist, high-performance **Flutter** camera application built **exclusively for macOS**. Tiny Cam leverages native macOS APIs to provide a seamless desktop experience with real-time filters, high-resolution photo capture, and video recording.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)

> [!IMPORTANT]  
> **macOS Exclusive:** This application is built using `camera_macos` and utilizes macOS-specific APIs. It is not compatible with iOS, Android, Windows, or Linux.

---

## ✨ Features

- **🖼️ High-Res Capture**: Save photos in high-resolution PNG format directly to your Downloads folder.
- **🎥 Video Recording**: Record smooth MP4 videos with a dedicated recording indicator.
- **🎨 Real-time Filters**: Choose from over 10+ professional filters including:
  - *Cyberpunk, Vintage, Polaroid, Sepia, Grayscale, Drama, Warm, Cool, and more.*
- **📟 Integrated Gallery**: View your captured media instantly with an in-app gallery.
- **⏯️ Native Video Support**: Generates high-quality thumbnails for videos and features a built-in video player.
- **🪞 Mirror Mode**: Toggle camera mirroring for perfect selfies.
- **💎 Premium UI**: Glassmorphic elements, smooth animations, and a responsive design tailored for the macOS desktop experience.

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **macOS**: This project uses `camera_macos` and is specifically tailored for the macOS platform.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/tiny_cam.git
   cd tiny_cam
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:

   ```bash
   flutter run -d macos
   ```

---

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI Framework.
- **[camera_macos](https://pub.dev/packages/camera_macos)** - Native macOS camera implementation.
- **[image](https://pub.dev/packages/image)** - Advanced image processing for filters.
- **[video_player](https://pub.dev/packages/video_player)** - Playback support for recorded videos.
- **[fc_native_video_thumbnail](https://pub.dev/packages/fc_native_video_thumbnail)** - High-speed native video thumbnail generation.

---

## 📂 Project Structure

- `lib/screens/`: Contains the main camera interface, gallery, and fullscreen viewers.
- `lib/services/`: Business logic for camera operations and image filter algorithms.
- `lib/widgets/`: Reusable UI components like custom buttons and toast notifications.
- `assets/`: Static resources used in the application.

---

## 📜 License

This project is private and intended for personal use or as a template. See `pubspec.yaml` for licensing details.

---

Developed with ❤️ using Flutter.
