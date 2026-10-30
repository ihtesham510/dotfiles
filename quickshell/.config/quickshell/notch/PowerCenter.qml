import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

Item {
    id: root
    focus: true

    property int current: 0
    readonly property int count: 5

    signal closeRequested

    function focusPanel(): void {
        root.forceActiveFocus();
    }

    // The Hyprland focus grab hands the keyboard to the notch a moment after
    // the mode changes, so the first attempt can land too early. Retry once
    // after the grab is in place, like the launcher does.
    onVisibleChanged: {
        if (visible) {
            focusPanel();
            Qt.callLater(focusPanel);
        }
    }

    Keys.onEscapePressed: event => root.handleEscape(event)

    function handleEscape(event): void {
        root.closeRequested();
    }

    function moveSelection(delta: int) {
        root.current = (root.current + delta + root.count) % root.count;
    }

    function runCommand(delta: int) {
        switch (delta) {
        case 0:
            // TODO: add command when a lockscreen is build in quickshell
            console.log('add lock screen');
            break;
        case 1:
            Quickshell.execDetached(["systemctl", "suspend"]);
            break;
        case 2:
            Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
            break;
        case 3:
            Quickshell.execDetached(["systemctl", "reboot"]);
            break;
        case 4:
            Quickshell.execDetached(["systemctl", "poweroff"]);
            break;
        }
    }

    Keys.onUpPressed: event => {
        root.moveSelection(-1);
        event.accepted = true;
    }

    Keys.onDownPressed: event => {
        root.moveSelection(1);
        event.accepted = true;
    }

    Keys.onReturnPressed: event => {
        root.runCommand(current);
        event.accepted = true;
    }

    Keys.onRightPressed: event => {
        root.moveSelection(1);
        event.accepted = true;
    }
    Keys.onLeftPressed: event => {
        root.moveSelection(-1);
        event.accepted = true;
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        Rectangle {
            id: lock
            readonly property int index: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 4
            radius: 12
            color: lock.index == root.current ? Theme.primary : Theme.surfaceHover
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runCommand(root.current)
            }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        root.current = lock.index;
                    }
                }
            }
            ColumnLayout {
                spacing: 6
                anchors.centerIn: parent
                Icon {
                    source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/svgs/lock.svg"
                    Layout.alignment: Qt.AlignHCenter
                    color: lock.index == root.current ? Theme.onPrimary : Theme.foreground
                    size: 34
                }
                Text {
                    text: "Lock"
                    Layout.alignment: Qt.AlignHCenter
                    color: lock.index == root.current ? Theme.onPrimary : Theme.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }
        Rectangle {
            id: suspend
            readonly property int index: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 4
            radius: 12
            color: suspend.index == root.current ? Theme.primary : Theme.surfaceHover
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runCommand(root.current)
            }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        root.current = suspend.index;
                    }
                }
            }
            ColumnLayout {
                spacing: 6
                anchors.centerIn: parent
                Icon {
                    source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/svgs/moon.svg"
                    Layout.alignment: Qt.AlignHCenter
                    color: suspend.index == root.current ? Theme.onPrimary : Theme.foreground
                    size: 34
                }
                Text {
                    text: "Suspend"
                    Layout.alignment: Qt.AlignHCenter
                    color: suspend.index == root.current ? Theme.onPrimary : Theme.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }
        Rectangle {
            id: logout
            readonly property int index: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 4
            radius: 12
            color: logout.index == root.current ? Theme.primary : Theme.surfaceHover
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runCommand(root.current)
            }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        root.current = logout.index;
                    }
                }
            }
            ColumnLayout {
                spacing: 6
                anchors.centerIn: parent
                Icon {
                    source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/svgs/logout.svg"
                    Layout.alignment: Qt.AlignHCenter
                    color: logout.index == root.current ? Theme.onPrimary : Theme.foreground
                    size: 34
                }
                Text {
                    text: "Log Out"
                    Layout.alignment: Qt.AlignHCenter
                    color: logout.index == root.current ? Theme.onPrimary : Theme.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }
        Rectangle {
            id: reboot
            readonly property int index: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 4
            radius: 12
            color: reboot.index == root.current ? Theme.primary : Theme.surfaceHover
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runCommand(root.current)
            }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        root.current = reboot.index;
                    }
                }
            }
            ColumnLayout {
                spacing: 6
                anchors.centerIn: parent
                Icon {
                    source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/svgs/reboot.svg"
                    Layout.alignment: Qt.AlignHCenter
                    color: reboot.index == root.current ? Theme.onPrimary : Theme.foreground
                    size: 34
                }
                Text {
                    text: "Reboot"
                    Layout.alignment: Qt.AlignHCenter
                    color: reboot.index == root.current ? Theme.onPrimary : Theme.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }
        Rectangle {
            id: shutdown
            readonly property int index: 4
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 4
            radius: 12
            color: shutdown.index == root.current ? Theme.primary : Theme.surfaceHover
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runCommand(root.current)
            }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        root.current = shutdown.index;
                    }
                }
            }
            ColumnLayout {
                spacing: 6
                anchors.centerIn: parent
                Icon {
                    source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/svgs/power.svg"
                    Layout.alignment: Qt.AlignHCenter
                    color: shutdown.index == root.current ? Theme.onPrimary : Theme.foreground
                    size: 34
                }
                Text {
                    text: "Shut down"
                    Layout.alignment: Qt.AlignHCenter
                    color: shutdown.index == root.current ? Theme.onPrimary : Theme.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }
    }
}
