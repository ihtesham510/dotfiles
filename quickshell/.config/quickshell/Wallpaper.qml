import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: wallpaper

    // The single source of truth. A future picker only needs to set this.
    property string current: Quickshell.env("HOME") + "/Pictures/Wallpapers/anime girl.jpg"
    property int fadeDuration: 700

    // qs ipc call wallpaper set /path/to/image.jpg
    IpcHandler {
        target: "wallpaper"
        function set(path: string): void {
            wallpaper.current = path;
        }
    }

    // One window per monitor
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: "black"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "wallpaper"

            property string target: wallpaper.current

            // Old image stays underneath while the new one fades in on top
            Image {
                id: back
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
            }

            Image {
                id: front
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: 0
                source: "file://" + target

                onStatusChanged: if (status === Image.Ready)
                    fade.restart()

                NumberAnimation {
                    id: fade
                    target: front
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: wallpaper.fadeDuration
                    easing.type: Easing.InOutQuad
                }
            }

            onTargetChanged: {
                back.source = front.source;   // keep showing the old wallpaper underneath
                front.opacity = 0;
                front.source = "file://" + target;
            }
        }
    }
}
