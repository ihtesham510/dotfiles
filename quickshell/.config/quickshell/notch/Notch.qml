import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs
import qs.notch.launcher
import qs.services

PanelWindow {
    id: root

    readonly property bool launcherOpen: NotchState.mode === NotchState.Mode.Launcher
    readonly property bool expanded: NotchState.mode === NotchState.Mode.Expand

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
    HyprlandFocusGrab {
        active: root.launcherOpen || root.expanded
        windows: [root]
        onCleared: NotchState.close()
    }

    // qs ipc call notch toggle
    // qs ipc call notch open launcher
    // qs ipc call notch open expand
    // qs ipc call notch close
    IpcHandler {
        target: "notch"

        function open(mode: string): void {
            if (mode === "launcher")
                NotchState.setMode(NotchState.Mode.Launcher);
            else if (mode === "expand")
                NotchState.setMode(NotchState.Mode.Expand);
        }

        function close(): void {
            NotchState.close();
        }

        function toggle(): void {
            NotchState.toggle(NotchState.Mode.Launcher);
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
            default:
                return "idle";
            }
        }
    }

    Rectangle {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true

        width: {
            switch (NotchState.mode) {
            case NotchState.Mode.Launcher:
                return Theme.launcherWidth;
            case NotchState.Mode.Expand:
                return Theme.expandedWidth;
            case NotchState.Mode.Hoverd:
                return Theme.collapsedWidth * 1.1;
            default:
                return Theme.collapsedWidth;
            }
        }
        height: {
            switch (NotchState.mode) {
            case NotchState.Mode.Launcher:
                return Theme.launcherHeight;
            case NotchState.Mode.Expand:
                return Theme.expandedHeight;
            case NotchState.Mode.Hoverd:
                return Theme.collapsedHeight * 1.1;
            default:
                return Theme.collapsedHeight;
            }
        }
        radius: {
            switch (NotchState.mode) {
            case NotchState.Mode.Launcher:
                return Theme.launcherRadius;
            case NotchState.Mode.Expand:
                return Theme.expandedHeight / 4;
            default:
                return Theme.collapsedHeight / 2;
            }
        }
        color: Theme.background

        Behavior on width {
            NumberAnimation {
                duration: Theme.expandDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Theme.expandDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: Theme.expandDuration
                easing.type: Easing.OutCubic
            }
        }

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) {
                    if (NotchState.mode === NotchState.Mode.Idle)
                        NotchState.setMode(NotchState.Mode.Hoverd);
                } else if (NotchState.mode === NotchState.Mode.Hoverd) {
                    NotchState.setMode(NotchState.Mode.Idle);
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.launcherOpen
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
            anchors.fill: parent
            expanded: NotchState.mode === NotchState.Mode.Expand
            hoverd: NotchState.mode == NotchState.Mode.Hoverd
            visible: !root.launcherOpen
        }

        Launcher {
            anchors.fill: parent
            visible: root.launcherOpen
            onCloseRequested: NotchState.close()
        }
    }
}
