pragma Singleton
import Quickshell
import QtQuick

// Shared visual constants. One place to change colors, sizes and timings.
Singleton {
    readonly property color background: "black"

    readonly property color foreground: "white"
    readonly property color muted: "#a0a0a0"
    readonly property color subtle: "#cccccc"

    readonly property color inactive: "#3a3a3a"
    readonly property color occupied: "#888888"

    readonly property color success: "#98c379"
    readonly property color danger: "#e06c75"

    // Surfaces used by the launcher / future panels
    readonly property color surface: "#1c1c1e"
    readonly property color surfaceHover: "#2a2a2d"
    readonly property color outline: "#2f2f33"
    readonly property color outlineFocus: "#4a4a50"

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
