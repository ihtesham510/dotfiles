import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs
import qs.notch.launcher
import qs.notch.wallpaper
import qs.services

PanelWindow {
    id: root

    readonly property bool launcherOpen: NotchState.mode === NotchState.Mode.Launcher
    readonly property bool wallpaperOpen: NotchState.mode === NotchState.Mode.ExpandedWide
    readonly property bool expanded: NotchState.mode === NotchState.Mode.Expand
    readonly property bool volumeOpen: NotchState.mode === NotchState.Mode.VolumeMeter
    readonly property bool brightnessOpen: NotchState.mode === NotchState.Mode.BrightnessMeter

    readonly property bool panelOpen: root.launcherOpen || root.wallpaperOpen || root.volumeOpen || root.brightnessOpen

    // 0 = pill, 1 = panel. Every morph step reads this, so the geometry, the
    // content crossfade and the focus handoff all stay on the same clock.
    property real panelAmount: root.panelOpen ? 1 : 0

    // True for the whole open/close animation (0.001 avoids a final-frame
    // flicker when the animation lands exactly on zero).
    readonly property bool panelMorph: root.panelAmount > 0.001

    // Geometry of the panel currently being shown. Latched so that closing
    // still knows which size to shrink from after the mode is already Idle.
    property int panelWidth: Theme.launcherWidth
    property int panelHeight: Theme.launcherHeight
    property int panelRadius: Theme.launcherRadius

    function latchPanel(width: int, height: int, radius: int): void {
        panelWidth = width;
        panelHeight = height;
        panelRadius = radius;
    }

    onLauncherOpenChanged: {
        if (launcherOpen)
            latchPanel(Theme.launcherWidth, Theme.launcherHeight, Theme.launcherRadius);
    }

    onWallpaperOpenChanged: {
        if (wallpaperOpen)
            latchPanel(Theme.expandedWideWidth, Theme.expandedWideHeight, Theme.expandedWideRadius);
    }

    onVolumeOpenChanged: {
        if (volumeOpen)
            latchPanel(Theme.volumeWidth, Theme.volumeHeight, Theme.volumeRadius);
    }

    onBrightnessOpenChanged: {
        if (brightnessOpen)
            latchPanel(Theme.brightnessWidth, Theme.brightnessHeight, Theme.brightnessRadius);
    }

    // Re-check the hover state once a closing morph has finished (the pointer
    // may have stayed over the pill the whole time).
    function checkHover(): void {
        if (hover.hovered && NotchState.mode === NotchState.Mode.Idle)
            NotchState.setMode(NotchState.Mode.Hoverd);
    }

    onPanelMorphChanged: {
        if (!panelMorph)
            Qt.callLater(checkHover);
    }

    Behavior on panelAmount {
        NumberAnimation {
            duration: Theme.launcherMorphDuration
            easing.type: Easing.InOutCubic
        }
    }

    // Switching directly between two panels (launcher -> wallpaper) resizes
    // smoothly instead of snapping.
    Behavior on panelWidth {
        NumberAnimation {
            duration: Theme.launcherMorphDuration
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on panelHeight {
        NumberAnimation {
            duration: Theme.launcherMorphDuration
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on panelRadius {
        NumberAnimation {
            duration: Theme.launcherMorphDuration
            easing.type: Easing.InOutCubic
        }
    }

    // Geometry the notch rests at when no panel is open.
    readonly property real idleWidth: {
        if (root.panelMorph)
            return Theme.collapsedWidth;

        switch (NotchState.mode) {
        case NotchState.Mode.Expand:
            return Theme.expandedWidth;
        case NotchState.Mode.Hoverd:
            return Math.round(Theme.collapsedWidth * 1.1);
        default:
            return Theme.collapsedWidth;
        }
    }

    readonly property real idleHeight: {
        if (root.panelMorph)
            return Theme.collapsedHeight;

        switch (NotchState.mode) {
        case NotchState.Mode.Expand:
            return Theme.expandedHeight;
        case NotchState.Mode.Hoverd:
            return Math.round(Theme.collapsedHeight * 1.1);
        default:
            return Theme.collapsedHeight;
        }
    }

    readonly property real idleRadius: {
        if (root.panelMorph)
            return Theme.collapsedHeight / 2;

        switch (NotchState.mode) {
        case NotchState.Mode.Expand:
            return Theme.expandedHeight / 4;
        case NotchState.Mode.Hoverd:
            return Theme.collapsedHeight * 0.55;
        default:
            return Theme.collapsedHeight / 2;
        }
    }

    anchors.top: true
    margins.top: 8
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Theme.collapsedHeight
    implicitWidth: 840
    implicitHeight: 800
    color: "transparent"

    mask: Region {
        item: island
    }

    // Hands the keyboard to the notch while a panel is open and fires
    // onCleared when the user clicks elsewhere, which closes it.
    //
    // The volume OSD is deliberately excluded: it is a passive indicator and
    // must not steal the keyboard from the focused window while the user is
    // pressing the volume keys.
    HyprlandFocusGrab {
        active: root.launcherOpen || root.wallpaperOpen || root.expanded
        windows: [root]
        onCleared: NotchState.close()
    }

    // qs ipc call notch toggle
    // qs ipc call notch open launcher
    // qs ipc call notch open wallpaper
    // qs ipc call notch open expand
    // qs ipc call notch close
    IpcHandler {
        target: "notch"

        function open(mode: string): void {
            if (mode === "launcher")
                NotchState.setMode(NotchState.Mode.Launcher);
            else if (mode === "wallpaper" || mode === "wide")
                NotchState.setMode(NotchState.Mode.ExpandedWide);
            else if (mode === "expand")
                NotchState.setMode(NotchState.Mode.Expand);
        }

        function close(): void {
            NotchState.close();
        }

        function toggle(): void {
            NotchState.toggle(NotchState.Mode.Launcher);
        }

        function toggleWallpaper(): void {
            NotchState.toggle(NotchState.Mode.ExpandedWide);
        }

        function state(): string {
            return NotchState.open ? "open" : "closed";
        }

        function mode(): string {
            switch (NotchState.mode) {
            case NotchState.Mode.Launcher:
                return "launcher";
            case NotchState.Mode.Expand:
                return "expand";
            case NotchState.Mode.Hoverd:
                return "hoverd";
            case NotchState.Mode.ExpandedWide:
                return "wallpaper";
            case NotchState.Mode.VolumeMeter:
                return "volume";
            case NotchState.Mode.BrightnessMeter:
                return "brightness";
            default:
                return "idle";
            }
        }
    }

    // Slight drop shadow under the island. A MultiEffect can only paint inside
    // its own item, so the shadow is rendered from a padded copy of the pill
    // shape — otherwise the blur would be cut off at the island's edges.
    Item {
        id: notchShadow
        anchors.centerIn: island
        width: island.width + 2 * Theme.notchShadowPadding
        height: island.height + 2 * Theme.notchShadowPadding

        Rectangle {
            anchors.centerIn: parent
            width: island.width
            height: island.height
            radius: island.radius
            color: Theme.background
        }
    }

    MultiEffect {
        anchors.fill: notchShadow
        source: notchShadow
        shadowEnabled: true
        shadowColor: "black"
        shadowBlur: 0.75
        shadowOpacity: 0.55
        shadowVerticalOffset: 4
    }

    Rectangle {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true

        // While a panel is open, the pill size is interpolated to the panel
        // size by panelAmount. Outside a morph the resting geometry is used,
        // and the Behaviors below animate the Expand / Hover transitions.
        width: root.panelMorph ? root.idleWidth + (root.panelWidth - root.idleWidth) * root.panelAmount : root.idleWidth
        height: root.panelMorph ? root.idleHeight + (root.panelHeight - root.idleHeight) * root.panelAmount : root.idleHeight
        radius: root.panelMorph ? root.idleRadius + (root.panelRadius - root.idleRadius) * root.panelAmount : root.idleRadius
        color: Theme.background

        Behavior on width {
            enabled: !root.panelOpen && !root.panelMorph
            NumberAnimation {
                duration: Theme.expandDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            enabled: !root.panelOpen && !root.panelMorph
            NumberAnimation {
                duration: Theme.expandDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on radius {
            enabled: !root.panelOpen && !root.panelMorph
            NumberAnimation {
                duration: Theme.expandDuration
                easing.type: Easing.OutCubic
            }
        }

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) {
                    if (!root.panelMorph && NotchState.mode === NotchState.Mode.Idle)
                        NotchState.setMode(NotchState.Mode.Hoverd);
                } else if (NotchState.mode === NotchState.Mode.Hoverd) {
                    NotchState.setMode(NotchState.Mode.Idle);
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.panelOpen && !root.panelMorph
            onClicked: NotchState.toggle(NotchState.Mode.Expand)
        }

        Item {
            anchors.fill: parent
            focus: root.expanded

            Keys.onPressed: event => {
                NotchState.close();
                event.accepted = true;
            }
        }

        // The idle content stays pinned to the pill's size while a panel is
        // morphing, so the clock never drifts to the middle of the growing
        // notch. It fades out at the halfway point of the growth.
        IdleContent {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.panelMorph ? Theme.collapsedWidth : parent.width
            height: root.panelMorph ? Theme.collapsedHeight : parent.height

            expanded: root.expanded
            hoverd: NotchState.mode === NotchState.Mode.Hoverd && !root.panelMorph

            visible: opacity > 0
            opacity: root.panelOpen ? (root.panelAmount < 0.5 ? 1 : 0) : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.contentFadeDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        Launcher {
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.launcherOpen ? (root.panelAmount >= 0.5 ? 1 : 0) : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.contentFadeDuration
                    easing.type: Easing.OutCubic
                }
            }

            onCloseRequested: NotchState.close()
        }

        WallpaperPicker {
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.wallpaperOpen ? (root.panelAmount >= 0.5 ? 1 : 0) : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.contentFadeDuration
                    easing.type: Easing.OutCubic
                }
            }

            onCloseRequested: NotchState.close()
        }
        VolumeMeter {
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.volumeOpen ? (root.panelAmount >= 0.5 ? 1 : 0) : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.contentFadeDuration
                    easing.type: Easing.OutCubic
                }
            }
            onCloseRequested: NotchState.close()
        }

        BrightnessMeter {
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.brightnessOpen ? (root.panelAmount >= 0.5 ? 1 : 0) : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.contentFadeDuration
                    easing.type: Easing.OutCubic
                }
            }
            onCloseRequested: NotchState.close()
        }
    }
}
