import QtQuick
import Quickshell.Hyprland
import qs

// Row of Hyprland workspace pills.
// When the notch is expanded we show two extra (empty) slots.
Row {
    id: root

    property bool expanded: false
    property int collapsedCount: 4
    property int expandedCount: 6

    spacing: 6

    Repeater {
        model: root.expanded ? root.expandedCount : root.collapsedCount

        Rectangle {
            id: ws
            required property int index

            readonly property int wsId: index + 1
            readonly property bool focused: Hyprland.focusedWorkspace?.id === wsId
            readonly property bool occupied: {
                const v = Hyprland.workspaces.values;
                for (let i = 0; i < v.length; i++)
                    if (v[i].id === wsId)
                        return true;
                return false;
            }
            width: focused ? 8 : 7.5
            height: focused ? 18 : 17.5
            radius: 8
            color: focused ? Theme.primary : (occupied ? Theme.occupied : Theme.inactive)

            Behavior on width {
                NumberAnimation {
                    duration: 200
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                onClicked: Hyprland.dispatch("workspace " + ws.wsId)
            }
        }
    }
}
