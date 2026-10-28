import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.services

// The wallpaper changer body. Fills the notch and is shown in ExpandedWide
// mode: a launcher-style search field over a horizontal, sliding carousel.
Item {
    id: root

    signal closeRequested

    readonly property var wallpapers: Wallpapers.search(search.text)

    function focusInput(): void {
        search.forceActiveFocus();
    }

    function reset(): void {
        search.text = "";

        const list = Wallpapers.all();
        let index = 0;
        for (let i = 0; i < list.length; i++) {
            if (list[i].path === Wallpapers.current) {
                index = i;
                break;
            }
        }

        carousel.currentIndex = list.length > 0 ? index : -1;
        snapToCurrent();
    }

    function targetX(index: int): real {
        // The header half-slot means item 0 is centred at contentX = -halfSlot.
        return -(carousel.width - carousel.slotWidth) / 2 + index * carousel.pitch;
    }

    function snapToCurrent(): void {
        if (carousel.count <= 0)
            return;

        slideAnim.stop();
        carousel.contentX = targetX(Math.max(0, Math.min(carousel.currentIndex, carousel.count - 1)));
    }

    function slideToCurrent(): void {
        if (carousel.count <= 0)
            return;

        slideAnim.to = targetX(Math.max(0, Math.min(carousel.currentIndex, carousel.count - 1)));
        slideAnim.restart();
    }

    function moveSelection(delta: int): void {
        if (carousel.count === 0)
            return;

        let base = carousel.currentIndex;
        if (base < 0)
            base = delta > 0 ? -1 : 0;

        carousel.currentIndex = (base + delta + carousel.count) % carousel.count;
    }

    function apply(index: int): void {
        const list = root.wallpapers;
        if (index < 0 || index >= list.length)
            return;

        Wallpapers.setCurrent(list[index].path);
        root.closeRequested();
    }

    function handleEscape(event): void {
        if (search.text.length > 0)
            search.text = "";
        else
            root.closeRequested();

        event.accepted = true;
    }

    onVisibleChanged: {
        if (visible) {
            reset();
            focusInput();
            Qt.callLater(focusInput);
        }
    }

    // Fallback when focus is not in the search field.
    Keys.onEscapePressed: event => root.handleEscape(event)
    Keys.onLeftPressed: event => {
        root.moveSelection(-1);
        event.accepted = true;
    }
    Keys.onRightPressed: event => {
        root.moveSelection(1);
        event.accepted = true;
    }

    // --- Search field -----------------------------------------------------

    Rectangle {
        id: searchBox
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 14
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        height: 44
        radius: 12
        color: "transparent"

        Behavior on border.color {
            ColorAnimation {
                duration: 140
            }
        }

        IconImage {
            id: searchIcon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 16
            source: Quickshell.iconPath("system-search", true)
        }

        Text {
            anchors.left: search.left
            anchors.verticalCenter: search.verticalCenter
            visible: search.text.length === 0
            text: "Search wallpapers…"
            color: Theme.muted
            font.pixelSize: 15
        }

        TextInput {
            id: search
            anchors.left: searchIcon.right
            anchors.leftMargin: 10
            anchors.right: hint.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            color: Theme.foreground
            font.pixelSize: 15
            selectionColor: Theme.success
            selectedTextColor: Theme.background
            selectByMouse: true
            clip: true

            onAccepted: root.apply(carousel.currentIndex)

            Keys.onEscapePressed: event => root.handleEscape(event)

            // Left/Right browse the carousel only when the field is empty;
            // with a query they move the text cursor instead.
            Keys.onLeftPressed: event => {
                if (search.text.length > 0)
                    return;
                root.moveSelection(-1);
                event.accepted = true;
            }
            Keys.onRightPressed: event => {
                if (search.text.length > 0)
                    return;
                root.moveSelection(1);
                event.accepted = true;
            }
            Keys.onUpPressed: event => {
                root.moveSelection(-1);
                event.accepted = true;
            }
            Keys.onDownPressed: event => {
                root.moveSelection(1);
                event.accepted = true;
            }
        }

        Text {
            id: hint
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "esc"
            color: Theme.muted
            font.pixelSize: 10
        }
    }

    Rectangle {
        id: divider
        anchors.top: searchBox.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        height: 1
        color: Theme.outline
    }

    // --- Carousel ---------------------------------------------------------

    Item {
        id: carouselArea
        anchors.top: divider.bottom
        anchors.topMargin: 10
        anchors.bottom: nameLabel.top
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right

        ListView {
            id: carousel
            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing: Theme.wallpaperSpacing
            interactive: false
            boundsBehavior: Flickable.StopAtBounds
            highlightFollowsCurrentItem: false
            highlightRangeMode: ListView.NoHighlightRange
            cacheBuffer: 400
            model: root.wallpapers

            readonly property int slotWidth: Theme.wallpaperSlot
            readonly property int pitch: slotWidth + spacing

            header: Item {
                width: (carousel.width - carousel.slotWidth) / 2
                height: 1
            }
            footer: Item {
                width: (carousel.width - carousel.slotWidth) / 2
                height: 1
            }

            delegate: WallpaperCard {
                required property var modelData
                required property int index

                width: carousel.slotWidth
                height: carousel.height
                path: modelData.path
                focused: index === carousel.currentIndex
                z: focused ? 2 : 1

                onActivated: root.apply(index)
            }

            onCurrentIndexChanged: if (visible)
                root.slideToCurrent()
            onWidthChanged: if (visible)
                root.snapToCurrent()

            onModelChanged: {
                if (count === 0) {
                    currentIndex = -1;
                } else if (currentIndex < 0 || currentIndex >= count) {
                    currentIndex = 0;
                }
                if (visible)
                    root.snapToCurrent();
            }

            onCountChanged: {
                if (count === 0) {
                    currentIndex = -1;
                } else if (currentIndex < 0) {
                    currentIndex = 0;
                } else if (currentIndex >= count) {
                    currentIndex = count - 1;
                }
            }
        }

        // Wheel over the carousel browses, like the arrow keys.
        WheelHandler {
            onWheel: event => {
                root.moveSelection(event.angleDelta.y > 0 ? -1 : 1);
                event.accepted = true;
            }
        }

        // Side fades: off-screen wallpapers dissolve into the notch instead of
        // being cut off by a hard edge.
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 130
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Theme.background
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0)
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 130
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0)
                }
                GradientStop {
                    position: 1.0
                    color: Theme.background
                }
            }
        }

        Text {
            anchors.centerIn: parent
            width: parent.width - 160
            horizontalAlignment: Text.AlignHCenter
            visible: carousel.count === 0
            text: search.text.length === 0 ? "No wallpapers found" : "No matches for \"" + search.text + "\""
            color: Theme.muted
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }
    }

    // --- Focused wallpaper name ------------------------------------------

    Text {
        id: nameLabel
        anchors.bottom: hintBar.top
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        height: 18
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideMiddle
        color: Theme.foreground
        font.pixelSize: 13
        text: {
            if (carousel.currentIndex < 0 || carousel.currentIndex >= root.wallpapers.length)
                return "";
            const w = root.wallpapers[carousel.currentIndex];
            return w.path === Wallpapers.current ? w.name + "   ·   current" : w.name;
        }
    }

    Text {
        id: hintBar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        color: Theme.muted
        font.pixelSize: 10
        text: "← → browse   ·   enter apply   ·   esc close"
    }

    NumberAnimation {
        id: slideAnim
        target: carousel
        property: "contentX"
        duration: Theme.wallpaperSlideDuration
        easing.type: Easing.OutCubic
    }
}
