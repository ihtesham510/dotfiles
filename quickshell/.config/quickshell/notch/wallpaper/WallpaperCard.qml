import QtQuick
import Quickshell.Widgets
import qs

// One wallpaper thumbnail in the horizontal carousel.
//
// The slot (this item) is as wide as an unfocused card. The card itself is
// larger and scaled down, so focusing it makes it grow over its neighbours
// instead of pushing the whole row around.
Item {
    id: root

    property string path
    property bool focused: false

    signal activated

    implicitWidth: Theme.wallpaperSlot

    ClippingRectangle {
        id: card

        anchors.centerIn: parent
        width: Theme.wallpaperCardWidth
        height: Theme.wallpaperCardHeight
        radius: 12
        color: Theme.surface
        border.width: root.focused ? 2 : 0
        border.color: Theme.foreground

        scale: root.focused ? Theme.wallpaperFocusScale : Theme.wallpaperIdleScale

        Behavior on scale {
            NumberAnimation {
                duration: Theme.wallpaperFocusDuration
                easing.type: Easing.OutCubic
            }
        }

        Image {
            anchors.fill: parent
            anchors.margins: card.border.width
            source: "file://" + root.path
            sourceSize.width: Theme.wallpaperCardWidth * 2
            sourceSize.height: Theme.wallpaperCardHeight * 2
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            clip: true
            opacity: status === Image.Ready ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Cards further from the centre sit in shadow.
        Rectangle {
            anchors.fill: parent
            radius: card.radius
            color: Theme.background
            opacity: root.focused ? 0 : 0.35

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.wallpaperFocusDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // The hit area lives inside the card so the enlarged, focused card is
        // clickable across its whole visible surface.
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activated()
        }
    }
}
