import QtQuick
import qs
import qs.services

// Date line, only visible while the notch is expanded.
Text {
    id: root

    property bool expanded: false

    color: Theme.muted
    font.pixelSize: 13
    text: Qt.formatDateTime(Clock.date, "dddd, d MMMM")
    opacity: root.expanded ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: 250
        }
    }
}
