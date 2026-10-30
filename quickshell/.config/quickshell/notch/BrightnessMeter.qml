import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import qs
import qs.services
import Quickshell
import Quickshell.Widgets

// Brightness OSD shown inside the notch. Same shape and behaviour as the
// volume meter: icon on the left, level bar in the middle, percentage on the
// right, sized to the collapsed notch.
//
// Pointer-only: it never takes keyboard focus. Hovering keeps it on screen and
// lets the mouse control it (wheel = step, click/drag on the bar = seek).
Item {
    id: root

    signal closeRequested

    readonly property int percent: Brightness.percent

    // One icon per level.
    readonly property string iconSource: {
        if (root.percent < 34)
            return Quickshell.iconPath("brightness-low-symbolic", true);
        if (root.percent < 67)
            return Quickshell.iconPath("display-brightness-symbolic", true);
        return Quickshell.iconPath("brightness-high-symbolic", true);
    }

    // ── Auto hide ───────────────────────────────────────────────────
    // Restarted on every brightness action. While the pointer is over the OSD
    // it keeps itself alive, so the bar stays usable with the mouse.
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

    // ── React to every brightness action ────────────────────────────
    Connections {
        target: Brightness

        function onBrightnessUpdated() {
            const mode = NotchState.mode;
            // Never replace a panel the user is working in.
            if (mode === NotchState.Mode.Launcher || mode === NotchState.Mode.ExpandedWide || mode === NotchState.Mode.ControlCenter)
                return;

            NotchState.setMode(NotchState.Mode.BrightnessMeter);
            hideTimer.restart();
        }
    }

    // Wheel anywhere on the OSD steps the brightness.
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (event.angleDelta.y === 0)
                return;
            Brightness.setPercent(root.percent + (event.angleDelta.y > 0 ? Brightness.wheelStep : -Brightness.wheelStep));
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

        IconImage {
            Layout.alignment: Qt.AlignVCenter
            implicitSize: 20
            source: root.iconSource

            // The brightness icons are symbolic (drawn with currentColor), so
            // they render black unless tinted to the theme foreground.
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: Theme.foreground
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
                width: parent.width * (root.percent / 100)
                color: Theme.primary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                function seek(x: real): void {
                    Brightness.setPercent((x / width) * 100);
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
            color: Theme.muted
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }
}
