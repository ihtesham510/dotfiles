import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import Quickshell
import Quickshell.Widgets

// Volume OSD shown inside the notch.
//
// Pointer-only: it never takes keyboard focus, so changing the volume from the
// keyboard keeps focus in the focused window. Hovering keeps it on screen and
// lets the mouse control it (wheel = step, click/drag on the bar = seek,
// click the icon = mute).
Item {
    id: root

    signal closeRequested

    readonly property bool muted: Volume.isMuted
    readonly property real level: Volume.volume
    readonly property int percent: Volume.volumePercent

    // One icon per level, plus the muted icon.
    readonly property string iconSource: {
        if (root.muted || root.level <= 0.001)
            return Quickshell.iconPath("audio-volume-muted", true);
        if (root.level < 0.34)
            return Quickshell.iconPath("audio-volume-low", true);
        if (root.level < 0.67)
            return Quickshell.iconPath("audio-volume-medium", true);
        return Quickshell.iconPath("audio-volume-high", true);
    }

    // ── Auto hide ───────────────────────────────────────────────────
    // Restarted on every volume action. While the pointer is over the OSD it
    // keeps itself alive, so the bar stays usable with the mouse.
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: {
            if (hover.hovered) {
                restart();
                return;
            }
            root.closeRequested();
        }
    }

    HoverHandler {
        id: hover
    }

    Connections {
        target: Volume

        function onVolumeUpdated() {
            const mode = NotchState.mode;
            if (mode === NotchState.Mode.Launcher || mode === NotchState.Mode.ExpandedWide || mode === NotchState.Mode.ControlCenter)
                return;

            NotchState.setMode(NotchState.Mode.VolumeMeter);
            hideTimer.restart();
        }
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (event.angleDelta.y === 0)
                return;
            Volume.changeVolume(event.angleDelta.y > 0 ? Volume.wheelStep : -Volume.wheelStep);
            event.accepted = true;
        }
    }

    // ── Content ─────────────────────────────────────────────────────
    // A single row the height of the collapsed notch: icon on the left, level
    // bar in the middle, percentage on the right.
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        // Volume icon — click to mute / unmute
        Item {
            id: iconButton
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 20
            implicitHeight: 20

            IconImage {
                anchors.centerIn: parent
                implicitSize: 20
                source: root.iconSource
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Volume.toggleMute()
            }
        }

        // Level bar — click or drag to seek
        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: 5
            radius: height / 2
            color: Theme.surfaceHover

            Rectangle {
                id: fill
                height: parent.height
                radius: parent.radius
                width: parent.width * root.level
                color: root.muted ? Theme.danger : Theme.primary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                function seek(x: real): void {
                    Volume.setVolume(Math.max(0, Math.min(1, x / width)));
                }

                onPressed: mouse => seek(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        seek(mouse.x);
                }
            }
        }

        // Fixed width so the bar doesn't resize between 9% and 100%.
        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 34
            horizontalAlignment: Text.AlignRight
            text: root.percent + "%"
            color: root.muted ? Theme.danger : Theme.muted
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }
}
