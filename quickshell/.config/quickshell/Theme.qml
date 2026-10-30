pragma Singleton
import Quickshell
import QtQuick
import qs.services

// Shared visual constants. One place to change colors, sizes and timings.
//
// Colours are Material 3 roles taken from the wallpaper by matugen (see
// services/Colours.qml). The second argument of each lookup is the old
// hand-picked colour, used until a palette exists, so the shell is never
// unstyled.
Singleton {
    // Notch / panel fill. surfaceContainer is the elevated surface Material
    // uses for floating sheets.
    readonly property color background: Colours.role("surface_container", "black")

    readonly property color foreground: Colours.role("on_surface", "white")
    readonly property color muted: Colours.role("on_surface_variant", "#a0a0a0")
    readonly property color subtle: Colours.role("on_surface", "#cccccc")

    readonly property color inactive: Colours.role("outline_variant", "#3a3a3a")
    readonly property color occupied: Colours.role("outline", "#888888")

    // Semantic colours. success is a custom matugen colour blended towards the
    // wallpaper hue; error is the Material error role.
    readonly property color success: Colours.role("success", "#98c379")
    readonly property color danger: Colours.role("error", "#e06c75")

    // Surfaces used by the launcher / future panels
    readonly property color surface: Colours.role("surface_container_high", "#1c1c1e")
    readonly property color surfaceHover: Colours.role("surface_container_highest", "#2a2a2d")
    readonly property color outline: Colours.role("outline_variant", "#2f2f33")
    readonly property color outlineFocus: Colours.role("primary", "#4a4a50")

    // Material accents, for anything that should read as "selected".
    readonly property color primary: Colours.role("primary", "white")
    readonly property color onPrimary: Colours.role("on_primary", "black")
    readonly property color secondary: Colours.role("secondary", "#cccccc")
    readonly property color tertiary: Colours.role("tertiary", "#cccccc")
    readonly property color error: Colours.role("error", "#e06c75")
    readonly property color surfaceLow: Colours.role("surface_container_low", "#1c1c1e")
    readonly property color surfaceHighest: Colours.role("surface_container_highest", "#2f2f33")

    // Notch geometry
    readonly property int collapsedWidth: 260
    readonly property int expandedWidth: 520
    readonly property int collapsedHeight: 34
    readonly property int expandedHeight: 70
    readonly property int margin: 18
    readonly property int expandDuration: 280

    // Notch <-> launcher morph
    readonly property int launcherMorphDuration: 340
    readonly property int contentFadeDuration: 110

    // Expanded modes (launcher, ...)
    readonly property int launcherWidth: 620
    readonly property int launcherHeight: 440
    readonly property int launcherRadius: 20

    // Wide panel (wallpaper picker, ...)
    readonly property int expandedWideWidth: 800
    readonly property int expandedWideHeight: 400
    readonly property int expandedWideRadius: 20

    // Volume OSD (same height as the collapsed notch, a bit wider)
    readonly property int volumeWidth: 320
    readonly property int volumeHeight: collapsedHeight
    readonly property int volumeRadius: collapsedHeight / 2

    // Brightness OSD — deliberately identical to the volume OSD.
    readonly property int brightnessWidth: volumeWidth
    readonly property int brightnessHeight: volumeHeight
    readonly property int brightnessRadius: volumeRadius

    // Wallpaper carousel
    readonly property int wallpaperCardWidth: 240
    readonly property int wallpaperCardHeight: 132
    readonly property real wallpaperFocusScale: 1.32
    readonly property real wallpaperIdleScale: 0.8
    readonly property int wallpaperSlot: 192
    readonly property int wallpaperSpacing: 50
    readonly property int wallpaperFocusDuration: 260
    readonly property int wallpaperSlideDuration: 300
}
