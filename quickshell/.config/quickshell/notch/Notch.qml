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
    readonly property bool powerPanelOpen: NotchState.mode === NotchState.Mode.PowerCenter

    readonly property bool panelOpen: NotchState.mode !== NotchState.Mode.Idle && NotchState.mode !== NotchState.Mode.Expand && NotchState.mode !== NotchState.Mode.Hoverd

    property real panelAmount: root.panelOpen ? 1 : 0

    readonly property bool panelMorph: root.panelAmount > 0.001

    property int panelWidth: Theme.launcherWidth
    property int panelHeight: Theme.launcherHeight
    property int panelRadius: Theme.launcherRadius

    function latchPanel(width: int, height: int, radius: int): void {
        panelWidth = width;
        panelHeight = height;
        panelRadius = radius;
    }
    onPowerPanelOpenChanged: {
        if (powerPanelOpen)
            latchPanel(Theme.powerPanelWidth, Theme.powerPanelHeight, Theme.powerPanelRadius);
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

    HyprlandFocusGrab {
        active: root.launcherOpen || root.wallpaperOpen || root.expanded || root.powerPanelOpen
        windows: [root]
        onCleared: NotchState.close()
    }

    IpcHandler {
        target: "notch"

        function open(mode: string): void {
            switch (mode) {
            case "laucher":
                NotchState.setMode(NotchState.Mode.Launcher);
                break;
            case "powerpanel":
                NotchState.setMode(NotchState.Mode.PowerCenter);
                break;
            case "wallpaper":
                NotchState.setMode(NotchState.Mode.ExpandedWide);
                break;
            case "expand":
                NotchState.setMode(NotchState.Mode.Expand);
                break;
            }
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
            case NotchState.Mode.PowerCenter:
                return "power";
            default:
                return "idle";
            }
        }
    }

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

        PowerCenter {
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.powerPanelOpen ? 1 : 0
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
